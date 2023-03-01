module "cdu_ha" {
  source = "../../../modules/aws/cdu"

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  vpc_tags    = var.vpc_tags
  subnet_tags = var.subnet_tags

  r53_zone_name = "cdu.samples.aws"

  kms_admin_roles = ["Admin"]

  enable_dual_stack = false

  cdu_params = {
    node_name   = var.node_name
    s3_bucket   = var.s3_bucket
    netmap_file = "netmap_a.cfg"
    users_file  = "userfile_a.cfg"
    overwrite   = "Y"
    #Use Defaults
    # cd_bin            = "IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z"
    # secret_key_prefix = "/${var.project}/${var.env_name}/cdu"
    # server_keycert    = "${lower(var.node_name)}.cdu-keycert.txt"
    # root_cert         = "ca-cert.cer"
    # issuing_cert      = "issuer-cert.cer"
    # global_folder     = "/opt/IBM/ConnectDirect"
    # local_folder      = "/home/cdadmin"
    # cdadmin_uid       = 2001
    # cdadmin_gid       = 2001
    # cw_log_group      = "/${var.project}/${var.env_name}/cdu/${var.node_name}"
    # proxy_url         = "NONE"
  }

  cdu_extra_files = {
    tokens = [
      {
        "name"  = "local_node_name"
        "value" = var.node_name
      },
      {
        "name"  = "remote_node_name"
        "value" = "USLDCDUC02"
      },
      {
        "name"  = "s3_bucket"
        "value" = var.s3_bucket
      },
    ]
    files = [
      {
        "source" = "test.txt"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test.txt"
      },
      {
        "source" = "test-l.cd"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test-l.cd"
      },
      {
        "source" = "test-l-r.cd"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test-l-r.cd"
      },
      {
        "source" = "test-r-l.cd"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test-r-l.cd"
      },
      {
        "source" = "test-l-s3.cd"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test-l-s3.cd"
      },
      {
        "source" = "test-s3-l.cd"
        "target" = "/home/cdadmin/cdunix/ndm/bin/test-s3-l.cd"
      },
    ]
  }

  #Use the following command to create the cert_password and keystore_password in parameter store, to avoid creating secret via Terraform
  #aws ssm put-parameter --name /${var.project}/${var.env_name}/cdu/${var.node_name}/cert_password --value <changeme> --type SecureString --overwrite
  #aws ssm put-parameter --name /${var.project}/${var.env_name}/cdu/${var.node_name}/keystore_password --value <changeme> --type SecureString --overwrite
  # cdu_secrets = {
  #   cert_password     = data.aws_ssm_parameter.seed_secret.value
  #   keystore_password = data.aws_ssm_parameter.seed_secret.value
  # }

  # if not provided, default will be used to create C:D Unix host
  # cdu_host_specs = {
  #   image_id      = "" #"ami-02e136e904f3da870"
  #   instance_type = "m5.large"
  #   #if ec2_instance_profile is not provided, CDU IAM role and instance profile will be created
  #   ec2_instance_profile       = ""
  #   ssh_key_name               = ""
  #   enable_detailed_monitoring = true
  #   backup_plan                = ""
  # }

  # if not provided, default will be use to create the encrypted the C:D Unix environment with new KMSs
  # cdu_encryption = {
  #   encrypted      = true
  #   ebs_kms_alias  = ""
  #   logs_kms_alias = ""
  #   ssm_kms_alias  = ""
  # }

  # if null, C:D Unix host will use EBS and will not be HA and Resilient
  #cdu_efs_specs = null

  # if not provided, default will be used to create encrypted EFS, EFS_SG and KMS
  # cdu_efs_specs = {
  #   #if efs_id is null, EFS will be created
  #   efs_id = var.efs_id
  #   #if efs_root is null, EFS will not be created, CDU will be installed on EBS
  #   #efs_root = null
  #   efs_root = "/${var.project}/${var.env_name}/cdu"
  #   #if security_group_tags is null, security group is created
  #   security_group_tags = var.security_group_tags

  #   encrypted = true
  #   #if kms_alias is null, new kms will be created for EFS
  #   kms_alias = null
  # }

  # cdu_ingress = {
  #   source_cidrs = [
  #     "0.0.0.0/0"
  #   ]
  #   ingress_ports = [
  #     "1363",
  #     "1364",
  #     "1365"
  #   ]
  # }

  # No target ports means no NLB will be created
  #cdu_lb_target_ports = []

  # In most cases default is good enough
  # cdu_lb_target_ports = [
  #   {
  #     purpose                = "cli"
  #     protocol               = "TCP"
  #     port                   = 1363
  #     deregistration_delay   = 300
  #     preserve_client_ip     = true
  #     hc_protocol            = "TCP"
  #     hc_port                = 1365
  #     hc_interval            = 30
  #     hc_healthy_threshold   = 3
  #     hc_unhealthy_threshold = 3
  #   },
  #   {
  #     purpose                = "comm"
  #     protocol               = "TCP"
  #     port                   = 1364
  #     deregistration_delay   = 300
  #     preserve_client_ip     = true
  #     hc_protocol            = "TCP"
  #     hc_port                = 1365
  #     hc_interval            = 30
  #     hc_healthy_threshold   = 3
  #     hc_unhealthy_threshold = 3
  #   },
  #   {
  #     purpose                = "fa"
  #     protocol               = "TCP"
  #     port                   = 1365
  #     deregistration_delay   = 300
  #     preserve_client_ip     = true
  #     hc_protocol            = "TCP"
  #     hc_port                = 1365
  #     hc_interval            = 30
  #     hc_healthy_threshold   = 3
  #     hc_unhealthy_threshold = 3
  #   }
  # ]
}
