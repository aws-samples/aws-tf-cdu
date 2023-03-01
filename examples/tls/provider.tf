terraform {
  required_version = ">= v1.3.9"
  # Set minimum required versions for providers using lazy matching
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }

  # Configure the S3 backend
  backend "s3" {
    encrypt        = true
    region         = "us-east-1"
    bucket         = "aws-tf-cdu-dev-terraform-state-bucket"
    dynamodb_table = "aws-tf-cdu-dev-terraform-state-locktable"
    key            = "aws-tf-cdu/examples/tls/terraform.tfstate"
  }
}

provider "tls" {
  #proxy = "your-proxy-url"
}
