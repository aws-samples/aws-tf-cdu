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
  description = "Project name (prefix/suffix) to be used on all the resources identification"
  type        = string
}

variable "env_name" {
  description = "Environment name e.g. dev, prod"
  type        = string
}

variable "tags" {
  description = "Common and mandatory tags for the resources"
  type        = map(string)
}

/*---------------------------------------------------------
Datasource Variables
---------------------------------------------------------*/
variable "vpc_tags" {
  description = <<-EOF
  Tags to discover target VPC, these tags should uniquely identify a VPC
  EOF
  type        = map(string)
}

variable "subnet_tags" {
  description = <<-EOF
  Tags to discover target subnets in the VPC, these tags should identify one or more subnets
  EOF
  type        = map(string)
}

/*---------------------------------------------------------
Compute Variables
---------------------------------------------------------*/
variable "kms_admin_roles" {
  description = <<-EOF
  List Administrator roles for KMS.
  Provide at least one Admin role if kms needs to be created for EBS, EFS, CW Logs or SSM
  e.g. ["Admin"]
  EOF
  type        = list(string)
  default     = []
}

variable "enable_dual_stack" {
  description = "Enable Dual Stack IPV4/IPV6 for the C:D Unix server and load-balancer. This is experimental."
  type        = bool
  default     = false
}

variable "cdu_host_specs" {
  description = <<-EOF
  Connect:Direct Unix Host specification.
  - `image_id`, required. Provide image_id of the AMI to use.
    if null or empty, a suitable public AMI will be used.
  - `instance_type`, required. Provide Amazon EC2 instance type e.g. "t2.micro"
  - `ec2_instance_profile`, required. Provide IAM instance profile that C:D Unix host will assume.
    If null or empty, a new role and instance profile will be created.
  - `ssh_key_name`, required. Provide name of an existing key pair, if you want to connect to the host via ssh.
    Host can always be accessed via SSM.
  - `enable_detailed_monitoring`, required. Should the detailed monitoring for the host be enabled.
  - `backup_plan`, required. AWS Backup service well-known tag for backup. e.g. "EVERY-DAY"
    This is applicable if AWS Backup service is being used for the backup.
  EOF
  type = object({
    image_id                   = string
    instance_type              = string
    ec2_instance_profile       = string
    ssh_key_name               = string
    enable_detailed_monitoring = bool
    backup_plan                = string
  })
  default = {
    image_id                   = ""
    instance_type              = "m5.large"
    ec2_instance_profile       = ""
    ssh_key_name               = ""
    enable_detailed_monitoring = false
    backup_plan                = ""
  }
}

variable "cdu_encryption" {
  description = <<-EOF
  Connect:Direct Unix solution encryption specification
  - `encrypted`, required. Should the EBS, CW logs and SSM be encrypted.
  - `ebs_kms_alias`, required. Use the given alias or create a new KMS like "alias/`project`/ebs" for encrypting EBS.
    Not applicable if `encrypted` is false.
  - `logs_kms_alias`, required. Use the given alias or create a new KMS like "alias/`project`/logs" for encrypting CW logs.
    Not applicable if `encrypted` is false.
  - `ssm_kms_alias`, required. Use the given alias or create a new KMS like "alias/`project`/ssm" for encrypting SSM.
    Not applicable if `encrypted` is false.
  EOF
  type = object({
    encrypted      = bool
    ebs_kms_alias  = string
    logs_kms_alias = string
    ssm_kms_alias  = string
  })
  default = {
    encrypted      = true
    ebs_kms_alias  = ""
    logs_kms_alias = ""
    ssm_kms_alias  = ""
  }
}

variable "cdu_efs_specs" {
  description = <<-EOF
  Connect:Direct Unix EFS storage specification.
  If null, the installation will not be HA and resilient as the C:D Unix server will use EBS.
  - `efs_id`, required. File System ID of EFS.
    if null, new EFS will be created.
  - `efs_root`, required. Path on EFS where C:D Unix will be installed.
    If null or empty "/`project`/`env_name`/cdu" will be assumed.
  - `security_group_tags`, required. Tags to discover an existing security group for the new EFS. These tags should uniquely identify a security group.
    if null, new Security Group will be created.
    Must be provided if `efs_id` is not null
  - `encrypted`, required. Should EFS be encrypted? Not applicable if `efs_id` is provided
  - `kms_alias`, required. Use the given alias or create a new KMS like "alias/`project`/efs".
    Not applicable if `efs_id` is provided
  EOF
  type = object({
    efs_id              = string
    efs_root            = string
    security_group_tags = map(string)
    encrypted           = bool
    kms_alias           = string
  })
  default = {
    efs_id              = null
    efs_root            = null
    security_group_tags = null
    encrypted           = true
    kms_alias           = null
  }
}

variable "cdu_params" {
  description = <<-EOF
  Connect:Direct Unix Node Parameters.
  - `node_name`, required. Name of the C:D node. e.g. "USLDCDUC01"
  - `s3_bucket`, required. Amazon S3 bucket name used for storing C:D Unix installation/config files. It may be same as the Terraform bootstrap bucket.
  - `cd_bin`, optional. IBM Connect:Direct installation file. Default "IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z"
  - `secret_key_prefix`, optional. System Manager Parameter Store key prefix used to store `cdu_secrets`. Default "/`project`/`env_name`/cdu"
  - `server_keycert`, optional. Name of the server keycert file. Default "`lower(node_name)`.cdu-keycert.txt"
  - `root_cert`, optional. Name of the root certificate file. Default "ca-cert.cer"
  - `issuing_cert`, optional. Name of the issuer certificate file. Default "issuer-cert.cer"
  - `netmap_file`, optional. Name of the `netmap` file (e.g. "netmap_a.cfg") in the "./`node_name`" folder. Default ""
  - `users_file`, optional. Name of the `userfile` file (e.g. "userfile_a.cfg") in the "./`node_name`" folder. Default ""
  - `global_folder`, optional. Global folder where C:D installation will be linked to. Default "/opt/IBM/ConnectDirect"
  - `local_folder`, optional. Local folder where C:D installation will be linked to. Default "/home/cdadmin"
  - `cdadmin_uid`, optional. POSIX UID for the cdadmin user. Default 2001
  - `cdadmin_gid`, optional.POSIX GID for the cdadmin user. Default 2001
  - `overwrite`, optional. Should existing installing be overwritten "Y" or "N". Default "Y"
    If any of the `cdu_params` are changed, then `overwrite` should be "Y" for the changes to take effect.
  - `cw_log_group`, optional. Amazon CloudWatch log group where C:D server logs will be sent. Default "/`project`/`env_name`/cdu/`node_name`"
  - `proxy_url`, optional. Proxy server URL, if your environment is using proxy server. Default `"NONE"`
  EOF
  type = object({
    node_name         = string
    s3_bucket         = string
    cd_bin            = optional(string)
    secret_key_prefix = optional(string)
    server_keycert    = optional(string)
    root_cert         = optional(string)
    issuing_cert      = optional(string)
    netmap_file       = optional(string)
    users_file        = optional(string)
    global_folder     = optional(string)
    local_folder      = optional(string)
    cdadmin_uid       = optional(number)
    cdadmin_gid       = optional(number)
    overwrite         = optional(string)
    cw_log_group      = optional(string)
    proxy_url         = optional(string)
  })
}

variable "cdu_ingress" {
  description = <<-EOF
  Connect:Direct Unix ingress specifications.
  - `source_cidrs`, required. List of source CIDRs that required access to C:D Unix, most probably on-premises CIDRs. e.g. ["10.1.0.0/16", "10.2.0.0/16"]
  - `ingress_ports`, required. List Ingress ports on which C:D Unix is providing inbound connections. e.g. [1363,1364,1365]
  EOF
  type = object({
    source_cidrs  = list(string)
    ingress_ports = list(string)
  })
  default = {
    source_cidrs  = ["0.0.0.0/0"]
    ingress_ports = ["1363", "1364", "1365"]
  }
}

variable "cdu_lb_target_ports" {
  description = <<-EOF
  Connect:Direct Unix Load-Balancer target(s) specifications.
  At least one target port is required to create load-balancer. Otherwise load-balancer will not be created.
  - `purpose`, required. Purpose for the LB target e.g. "cli", "comm", or "fa"
  - `protocol`, required. Backend protocol where CDU host is listening for this `purpose`. e.g. "tcp"
  - `port`, required. Backend port where CDU host is listening for this `purpose`. e.g. 1363, 1364, or 1365
  - `deregistration_delay`, required. The time to wait for in-flight requests to complete while de-registering a target. e.g. 300
  - `preserve_client_ip`, required. Preserve client IP addresses and ports in the packets forwarded to targets. e.g. true
  - `hc_protocol`, required. Health check protocol e.g. "TCP"
  - `hc_port`, required. The port the LB uses when performing health checks on target. e.g. 1365
  - `hc_interval`, required. Time between health checks of an individual target. e.g. 30
  - `hc_healthy_threshold`, required. The number of consecutive health checks successes required before considering an unhealthy target healthy. e.g. 3
  - `hc_unhealthy_threshold`, required. The number of consecutive health check failures required before considering a target unhealthy. e.g. 3
  EOF
  type = list(object({
    purpose                = string
    protocol               = string
    port                   = number
    deregistration_delay   = number
    preserve_client_ip     = bool
    hc_protocol            = string
    hc_port                = number
    hc_interval            = number
    hc_healthy_threshold   = number
    hc_unhealthy_threshold = number
  }))
  default = [
    {
      purpose                = "cli"
      protocol               = "TCP"
      port                   = 1363
      deregistration_delay   = 300
      preserve_client_ip     = true
      hc_protocol            = "TCP"
      hc_port                = 1365
      hc_interval            = 30
      hc_healthy_threshold   = 3
      hc_unhealthy_threshold = 3
    },
    {
      purpose                = "comm"
      protocol               = "TCP"
      port                   = 1364
      deregistration_delay   = 300
      preserve_client_ip     = true
      hc_protocol            = "TCP"
      hc_port                = 1365
      hc_interval            = 30
      hc_healthy_threshold   = 3
      hc_unhealthy_threshold = 3
    },
    {
      purpose                = "fa"
      protocol               = "TCP"
      port                   = 1365
      deregistration_delay   = 300
      preserve_client_ip     = true
      hc_protocol            = "TCP"
      hc_port                = 1365
      hc_interval            = 30
      hc_healthy_threshold   = 3
      hc_unhealthy_threshold = 3
    }
  ]
}

variable "cdu_extra_files" {
  description = <<-EOF
  List of Connect:Direct Unix extra files that will be copied over to IBM C:D Unix server. These files may be tokenized files, where tokens will be replaced.
  - `tokens`, required. List of tokens with `name` and `value`. These tokens can be used in the `files`.
  - `files`, required. List of files with `source` and `target` that will be copied over to IBM C:D Unix server.
  - `files.source`, required. Name of the file in the "./`node_name`" folder. e.g. "test-l.cd"
  - `files.target`, required. Full path on the C:D Unix server where file will be copied (must include file name). e.g. "/home/cdadmin/cdunix/ndm/bin/test-l.cd"
  EOF
  type = object({
    tokens = list(object({
      name  = string
      value = string
    }))
    files = list(object({
      source = string
      target = string
    }))
  })
  default = null
}

variable "cdu_secrets" {
  description = <<-EOF
  Connect:Direct Unix Secrets. These secrets are created in the System Manager Parameter Store.
  These are seed secrets and can/must change after creation.
  It is encouraged to create these secrets outside the Terraform.
  - `cert_password`, required. it is the password that is used to create the encrypted server private key.
  - `keystore_password`, required. it is the password that is used to protect the keystore on the server.
  EOF
  type = object({
    cert_password     = string
    keystore_password = string
  })
  default   = null
  sensitive = true
}

/*---------------------------------------------------------
R53 Variables
---------------------------------------------------------*/
variable "r53_zone_name" {
  description = "Route 53 Zone basename"
  type        = string
  default     = ""
}
