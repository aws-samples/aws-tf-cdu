/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
variable "region" {
  description = "The AWS Region e.g. us-east-1 for the environment"
  type        = string
}

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
variable "project" {
  description = "Project to be used on all the resources identification"
  type        = string
}

variable "env_name" {
  description = "Environment name e.g. dev, prod"
  type        = string
}

variable "tags" {
  description = "Mandatory tags for the resources"
  type        = map(string)
}

/*---------------------------------------------------------
Datasource Variables
---------------------------------------------------------*/
variable "vpc_tags" {
  description = "Tags used for filtering datasource aws_vpc for VPC"
  type        = map(string)
}

variable "subnet_tags" {
  description = "Tags used for filtering datasource aws_subnets for VPC"
  type        = map(string)
}

/*---------------------------------------------------------
CDU Variables
---------------------------------------------------------*/
variable "node_name" {
  description = "Unique Node Name"
  type        = string
}

variable "s3_bucket" {
  description = "Amazon S3 bucket name where cdu host related files are uploaded"
  type        = string
}
