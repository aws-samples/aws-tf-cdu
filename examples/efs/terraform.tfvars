/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "efs-shared"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "efs-shared"
}

/*---------------------------------------------------------
Datasource Variables
---------------------------------------------------------*/
#Make sure that target VPC is identified uniquely via these tags
vpc_tags = {
  "efs/shared" = "1"
  "Env"        = "DEV"
}

#Make sure that target subnets are tagged correctly
subnet_tags = {
  "efs/shared" = "1"
  "Env"        = "DEV"
}

/*---------------------------------------------------------
EFS Variables
---------------------------------------------------------*/
#Create EFS
efs_id = null
#Create SG
security_group_tags = null
#No EFS Access Point
efs_access_point_specs = []
