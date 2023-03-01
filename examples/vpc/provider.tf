terraform {
  required_version = ">= v1.3.9"
  # Set minimum required versions for providers using lazy matching
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0"
    }
  }

  # Configure the S3 backend
  backend "s3" {
    encrypt        = true
    region         = "us-east-1"
    bucket         = "aws-tf-cdu-dev-terraform-state-bucket"
    dynamodb_table = "aws-tf-cdu-dev-terraform-state-locktable"
    key            = "vpc/terraform.tfstate"
  }
}

# Configure the AWS Provider to assume_role and set default region
provider "aws" {
  region = var.region
}
