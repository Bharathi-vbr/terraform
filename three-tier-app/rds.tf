####################################################
# rds.tf - defensive RDS module: supports named DBs, unnamed RDS engines, and Aurora
# Assumptions:
# - module.vpc.private_subnets (list) and module.vpc.vpc_id exist
# - aws_security_group.instance_sg exists (app instances SG)
# - random provider available
####################################################

locals {
  db_identifier_base = replace(lower(var.db_name), "_", "-")
  db_identifier_cut  = substr("tf-${local.db_identifier_base}", 0, 63)
  db_identifier      = regexreplace(local.db_identifier_cut, "-+$", "")

  # categorize engines
  engines_named_db = ["mysql", "postgres", "mariadb"]         # engines that accept the `name` attribute on aws_db_instance
  engines_rds_instance = concat(local.engines_named_db, ["sqlserver-ex", "sqlserver-web", "sqlserver-ee", "sqlserver-se"])
  engine_is_rds_instance = contains(local.engines_rds_instance, var.db_engine)
  engine_is_named_db     = contains(local.engines_named_db, var.db_engine)
  engine_is_aurora       = startswith(var.db_engine, "aurora")
}

############################
# DB subnet group (private subnets)
############################
resource "aws_db_subnet_group" "rds" {
  name       = "tf-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = { Name = "tf-rds-subnet-group" }
}

############################
# RDS Security Group
############################
resource "aws_security_group" "rds_sg" {
  name        = "tf-rds-sg"
  description = "Allow DB access from app instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "App -> RDS"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tf-rds-sg" }
}

############################
# Random password and secret container
############################
resource "random_password" "db" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name        = replace("tf-${var.db_name}-db-credentials", "/", "-")
  description = "RDS master credentials for ${var.db_name}"
  tags = { Name = "tf-${var.db_name}-db-secret" }
}

############################
# Single-instance RDS WITH `name` (mysql/postgres/mariadb)
############################
resource "aws_db_instance" "rds_named" {
  count = local.engine_is_named_db ? 1 : 0

  identifier              = local.db_identifier
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type

  # This attribute is ONLY included for engines that support it
  #name                    = var.db_name
  username                = var.db_username
  password                = random_password.db.result
  port                    = var.db_port

  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  multi_az                = var.db_multi_az
  publicly_accessible     = false
  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  apply_immediately = true

  tags = { Name = "tf-${var.db_name}" }
}

############################
# Single-instance RDS WITHOUT `name` (SQL Server etc.)
############################
resource "aws_db_instance" "rds_unnamed" {
  count = (local.engine_is_rds_instance && !local.engine_is_named_db) ? 1 : 0

  identifier              = local.db_identifier
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type

  # DO NOT set `name` here — SQL Server engines don't accept it in the provider
  username                = var.db_username
  password                = random_password.db.result
  port                    = var.db_port

  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  multi_az                = var.db_multi_az
  publicly_accessible     = false
  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  apply_immediately = true

  tags = { Name = "tf-${var.db_name}" }
}

############################
# Aurora cluster + instances (if engine startswith "aurora")
############################
resource "aws_rds_cluster" "cluster" {
  count = local.engine_is_aurora ? 1 : 0

  cluster_identifier     = local.db_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = { Name = "tf-${var.db_name}-cluster" }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
 # count = local.engine_is_aurora ? max(1, var.db_cluster_instance_count) : 0

  identifier         = "${local.db_identifier}-inst-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.cluster[0].id
  instance_class     = var.db_instance_class
  engine             = var.db_engine
  engine_version     = var.db_engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.rds.name

  tags = { Name = "tf-${var.db_name}-cluster-inst" }
}

############################
# Secrets Manager version: write the right endpoint depending on which resource exists
############################
resource "aws_secretsmanager_secret_version" "db_version" {
  secret_id     = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = var.db_engine
    host     = try(
                 aws_db_instance.rds_named[0].address,
                 aws_db_instance.rds_unnamed[0].address,
                 aws_rds_cluster.cluster[0].endpoint,
                 ""
               )
    port     = try(
                 aws_db_instance.rds_named[0].port,
                 aws_db_instance.rds_unnamed[0].port,
                 aws_rds_cluster.cluster[0].port,
                 var.db_port
               )
    dbname   = var.db_name
  })
}

############################
# Outputs
############################
output "rds_identifier" {
  value = try(aws_db_instance.rds_named[0].id, aws_db_instance.rds_unnamed[0].id, aws_rds_cluster.cluster[0].id, "")
}

output "rds_endpoint" {
  value = try(aws_db_instance.rds_named[0].address, aws_db_instance.rds_unnamed[0].address, aws_rds_cluster.cluster[0].endpoint, "")
}

output "rds_port" {
  value = try(aws_db_instance.rds_named[0].port, aws_db_instance.rds_unnamed[0].port, aws_rds_cluster.cluster[0].port, var.db_port)
}
