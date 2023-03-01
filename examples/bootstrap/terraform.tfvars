/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
tags = {
  Env     = "DEV"
  Project = "aws-tf-cdu"
}

/*---------------------------------------------------------
Bootstrap Variables
---------------------------------------------------------*/
s3_statebucket_name   = "aws-tf-cdu-dev-terraform-state-bucket"
dynamo_locktable_name = "aws-tf-cdu-dev-terraform-state-locktable"
