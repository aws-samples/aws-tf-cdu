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
      version = ">= 4.0.1"
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
}
