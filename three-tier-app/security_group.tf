# security_groups.tf (root-level)
# Creates ALB, web, app, and DB security groups and wires them together.
# Expects your VPC module to be called "module.vpc" and to expose `vpc_id`.

locals {
  name_prefix = coalesce(var.aws_profile, "three-tier")
}

# ALB security group — allows HTTP/HTTPS from Internet
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for ALB (allows inbound HTTP/HTTPS from internet)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-alb-sg" }
}

# Web tier SG — allow only ALB to talk to web instances on port 80
resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-web-sg"
  description = "Web tier SG; only ALB can reach web instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow ALB to web (HTTP)"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-web-sg" }
}

# App tier SG — allow only web or ALB to reach app instances on port 8080
resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-app-sg"
  description = "App tier SG; only ALB/web can reach app instances (port 8080)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow ALB to app (HTTP alt)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb_sg.id,
      aws_security_group.web_sg.id
    ]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-app-sg" }
}

# DB SG — allow only app SG to access DB port (example: MySQL 3306)
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "DB SG; only app tier can connect to DB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow app tier to DB (MySQL)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-db-sg" }
}
