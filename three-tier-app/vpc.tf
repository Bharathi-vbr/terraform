data "aws_availability_zones" "available" {}
module "VPC" {
  source = "./modules/vpc"
  name            = "test-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}