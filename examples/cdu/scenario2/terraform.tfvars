/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "scenario2-cdu"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "scenario2-cdu"
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
node_name = "USLDCDUC02"

s3_bucket = "aws-tf-cdu-dev-terraform-state-bucket"

#Use Existing EFS
efs_id = "fs-00000000000000000" //"your-efs-id"

#Use existing EFS SG
security_group_tags = {
  Name = "efs-shared-common-efs-sg"
  Env  = "DEV"
}
