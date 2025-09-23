variable "aws_region" {
    description = "AWS region"
  type        = string  
  
}
variable "project_name" {
  description = "Project name prefix"
  type        = string
}
variable "public_subnet_cidrs" {
  description = "CIDR for public subnet"
  type        = string
}
variable "availability_zone" {
  description = "AZ (optional); used for subnet placement"
  type        = string
}
variable "user_data_file" {
    description = "Path to the EC2 userdata script file"
  type        = string
}
variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for your domain"
  type        = string
}
variable "domain_name" {
  description = "Fully qualified domain name to use (e.g. example.com)"
  type        = string
}
variable "create_acm_certificate" {
  description = "Whether to request an ACM certificate (DNS validation)"
  type        = bool
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI id for EC2 (Amazon Linux 2 recommended)"
  type        = string
}
variable "key_name" {
  description = "Existing EC2 Key Pair name (for SSH)."
  type        = string
}
