//---------------------------------------------------------//
// Provider Variable
//---------------------------------------------------------//
variable "region" {
  description = "The AWS Region e.g. us-east-1 for the environment"
  type        = string
}

//---------------------------------------------------------//
// Common Variables
//---------------------------------------------------------//
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

//---------------------------------------------------------//
// Datasource Variables
//---------------------------------------------------------//
variable "vpc_tags" {
  description = "Tags used for filtering datasource aws_vpc for VPC"
  type        = map(string)
}

variable "subnet_tags" {
  description = "Tags used for filtering datasource aws_subnets for VPC"
  type        = map(string)
}

//---------------------------------------------------------//
// EFS Variables
//---------------------------------------------------------//
variable "efs_id" {
  description = "EFS File System Id"
  type        = string
  default     = null
}

variable "security_group_tags" {
  description = "Tags used for finding EFS Security Group"
  type        = map(string)
  default     = null
}

variable "efs_access_point_specs" {
  description = "List of EFS Access Point Specs to be created. It can be empty list."
  type = list(object({
    efs_name        = string # unique name e.g. common
    efs_ap          = string # unique name e.g. common_sftp
    uid             = number
    gid             = number
    secondary_gids  = list(number)
    root_path       = string # e.g. /{env}/{project}/{purpose}/{name}
    owner_uid       = number # e.g. 0
    owner_gid       = number # e.g. 0
    root_permission = string # e.g. 0755
    principal_arns  = list(string)
  }))
  default = []
}
