terraform {
required_version = ">=1.5.0"
required_providers {
 aws  = {
    source = "hashicorp/aws"
    version = "~>5.0"
 }
}

#remote state backend
#backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "aws-ec2-userdata-webserver/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }

}
provider "aws" {
  region = var.aws_region
}