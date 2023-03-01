/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "aws-tf-cdu-vpc"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "aws-tf-cdu-vpc"
}

/*---------------------------------------------------------
VPC Variables
---------------------------------------------------------*/
vpc_tags = {
  "efs/shared"       = "1"
  "ibm/sterling/cdu" = "1"
  "Env"              = "DEV"
}

vpc_public_subnet_tags = {}

vpc_private_subnet_tags = {
  "efs/shared"       = "1"
  "ibm/sterling/cdu" = "1"
  "Env"              = "DEV"
}

enable_dual_stack = false

r53_zone_names = ["cdu.samples.aws"]
