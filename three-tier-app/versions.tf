terraform {
    required_version = ">= 1.3.0"
 required_providers {
       aws = {
        source = "hashicorp/aws"
        version = ">= 4.0"
       }
 }
}

# Optional: uncomment and configure a remote backend (S3 + DynamoDB) later
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "three-tier/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
#}
