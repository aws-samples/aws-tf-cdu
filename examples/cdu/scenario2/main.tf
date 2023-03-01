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

  cdu_params = {
    node_name         = var.node_name
    s3_bucket         = var.s3_bucket
    cd_bin            = "IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z"
    secret_key_prefix = "/${var.project}/${var.env_name}/cdu"
    server_keycert    = "${lower(var.node_name)}.cdu-keycert.txt"
    root_cert         = "ca-cert.cer"
    issuing_cert      = "issuer-cert.cer"
    netmap_file       = "netmap_a.cfg"
    users_file        = "userfile_a.cfg"
    global_folder     = "/opt/IBM/ConnectDirect"
    local_folder      = "/home/cdadmin"
    cdadmin_uid       = 2001
    cdadmin_gid       = 2001
    overwrite         = "Y"
    cw_log_group      = "/${var.project}/${var.env_name}/cdu/${var.node_name}"
    proxy_url         = "NONE"
  }

  cdu_extra_files = {
    tokens = [
      {
        "name"  = "local_node_name"
        "value" = var.node_name
      },
      {
        "name"  = "remote_node_name"
        "value" = "USLDCDUC01"
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

  cdu_efs_specs = {
    #if efs_id is null, EFS will be created
    efs_id   = var.efs_id
    efs_root = "/${var.project}/${var.env_name}/cdu"
    #if security_group_tags is null, security group is created
    security_group_tags = var.security_group_tags

    encrypted = true
    #if kms_alias is null, new kms will be created for EFS
    kms_alias = null
  }
}
