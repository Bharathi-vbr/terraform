variable "aws_region" {
  description = "AWS region where resources will be created"
  type = string
}
variable "aws_profile" {
  description = "AWS CLI profile name to use (leave empty to use default)"
  type        = string
  default     = ""
}
# variables.tf additions for RDS
variable "db_engine" {
  description = "RDS engine (mysql | postgres)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "appadmin"
}

variable "db_port" {
  description = "DB port"
  type        = number
  default     = 3306
}

variable "db_multi_az" {
  description = "Enable multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "Backup retention"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on destroy (set false in prod)"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Enable deletion protection (recommended for prod)"
  type        = bool
  default     = false
}
variable "db_name" {
  description = "RDS database name (start with a letter; letters, digits and underscores only; max 63 chars)"
  type        = string
  default     = "three_tier_app_db"
}
variable "domain_name" {
  description = "Domain name to point at the ALB (e.g., app.example.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
}

variable "create_ipv6" {
  description = "Whether to create an AAAA alias record"
  type        = bool
  default     = false
}

