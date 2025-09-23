variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}
variable "name" {
  description = "Prefix for resource names"
  type = string
}
variable "tags" {
  description = "Map of tags to apply to created resources"
  type = map(string)
}
variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones (must match subnet counts)"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
