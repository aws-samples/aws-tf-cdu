/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "scenario1-cdu"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "scenario1-cdu"
}

/*---------------------------------------------------------
Datasource Variables
---------------------------------------------------------*/
#Make sure that target VPC is identified uniquely via these tags
vpc_tags = {
  "ibm/sterling/cdu" = "1"
  "Env"              = "DEV"
}

#Make sure that target subnets are tagged correctly
subnet_tags = {
  "ibm/sterling/cdu" = "1"
  "Env"              = "DEV"
}

/*---------------------------------------------------------
CDU Variables
---------------------------------------------------------*/
node_name = "USLDCDUC01"

s3_bucket = "aws-tf-cdu-dev-terraform-state-bucket"
