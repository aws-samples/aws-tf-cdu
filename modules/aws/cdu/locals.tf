locals {
  cdu_params = {
    node_name         = var.cdu_params.node_name
    s3_bucket         = var.cdu_params.s3_bucket
    cd_bin            = try(length(var.cdu_params.cd_bin), 0) != 0 ? var.cdu_params.cd_bin : "IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z"
    secret_key_prefix = try(length(var.cdu_params.secret_key_prefix), 0) != 0 ? var.cdu_params.secret_key_prefix : "/${var.project}/${var.env_name}/cdu"
    server_keycert    = try(length(var.cdu_params.server_keycert), 0) != 0 ? var.cdu_params.server_keycert : "${lower(var.cdu_params.node_name)}.cdu-keycert.txt"
    root_cert         = try(length(var.cdu_params.root_cert), 0) != 0 ? var.cdu_params.root_cert : "ca-cert.cer"
    issuing_cert      = try(length(var.cdu_params.issuing_cert), 0) != 0 ? var.cdu_params.issuing_cert : "issuer-cert.cer"
    netmap_file       = try(length(var.cdu_params.netmap_file), 0) != 0 ? var.cdu_params.netmap_file : ""
    users_file        = try(length(var.cdu_params.users_file), 0) != 0 ? var.cdu_params.users_file : ""
    global_folder     = try(length(var.cdu_params.global_folder), 0) != 0 ? var.cdu_params.global_folder : "/opt/IBM/ConnectDirect"
    local_folder      = try(length(var.cdu_params.local_folder), 0) != 0 ? var.cdu_params.local_folder : "/home/cdadmin"
    cdadmin_uid       = try(abs(var.cdu_params.cdadmin_uid), 0) != 0 ? var.cdu_params.cdadmin_uid : 2001
    cdadmin_gid       = try(abs(var.cdu_params.cdadmin_gid), 0) != 0 ? var.cdu_params.cdadmin_gid : 2001
    overwrite         = try(length(var.cdu_params.overwrite), 0) != 0 ? var.cdu_params.overwrite : "Y"
    cw_log_group      = try(length(var.cdu_params.cw_log_group), 0) != 0 ? var.cdu_params.cw_log_group : "/${var.project}/${var.env_name}/cdu/${var.cdu_params.node_name}"
    proxy_url         = try(length(var.cdu_params.proxy_url), 0) != 0 ? var.cdu_params.proxy_url : "NONE"
  }
}

locals {
  cdu_encrypted   = try(var.cdu_encryption.encrypted, true)
  create_ebs_kms  = local.cdu_encrypted && try(length(var.cdu_encryption.ebs_kms_alias), 0) == 0
  create_logs_kms = local.cdu_encrypted && try(length(var.cdu_encryption.logs_kms_alias), 0) == 0
  create_ssm_kms = local.cdu_encrypted && try(length(var.cdu_encryption.ssm_kms_alias), 0) == 0 && try(
  length(var.cdu_secrets.cert_password), 0) != 0 && try(length(var.cdu_secrets.keystore_password), 0) != 0

  create_kms = local.create_ebs_kms || local.create_logs_kms || local.create_ssm_kms

  ebs_kms_alias  = try(length(var.cdu_encryption.ebs_kms_alias), 0) != 0 ? var.cdu_encryption.ebs_kms_alias : local.create_kms ? "alias/${var.project}/ebs" : null
  logs_kms_alias = try(length(var.cdu_encryption.logs_kms_alias), 0) != 0 ? var.cdu_encryption.logs_kms_alias : local.create_kms ? "alias/${var.project}/logs" : null
  ssm_kms_alias  = try(length(var.cdu_encryption.ssm_kms_alias), 0) != 0 ? var.cdu_encryption.ssm_kms_alias : local.create_kms ? "alias/${var.project}/ssm" : null
}

locals {
  image_id = try(length(var.cdu_host_specs.image_id), 0) == 0 ? data.aws_ami.cdu_ami[0].id : var.cdu_host_specs.image_id
}

locals {
  create_cdu_role      = try(var.cdu_host_specs.ec2_instance_profile, "") != "" ? false : true
  cdu_role_name        = "CustomerManaged-${var.project}-${local.cdu_params.node_name}-role-${var.env_name}"
  cdu_instance_profile = local.create_cdu_role ? "CustomerManaged-${var.project}-${local.cdu_params.node_name}-role-${var.env_name}" : var.cdu_host_specs.ec2_instance_profile
}

locals {
  use_efs       = var.cdu_efs_specs != null
  create_efs    = local.use_efs && try(length(var.cdu_efs_specs.efs_id), 0) == 0
  create_efs_sg = local.create_efs && try(length(var.cdu_efs_specs.security_group_tags), 0) == 0
  efs_root      = try(length(var.cdu_efs_specs.efs_root), 0) != 0 ? var.cdu_efs_specs.efs_root : "/${var.project}/${var.env_name}/cdu"
}

locals {
  cdu_required_files = [
    {
      "source" = "${path.module}/files/aws-install-cd.sh"
      "target" = "cdu/aws-install-cd.sh"
    },
    {
      "source" = "${path.module}/files/optionsFile.txt"
      "target" = "cdu/optionsFile.txt"
    },
    {
      "source" = "${path.module}/files/amazon-cloudwatch-agent-all.json"
      "target" = "cdu/amazon-cloudwatch-agent-all.json"
    },
    {
      "source" = "${path.module}/files/amazon-cloudwatch-agent-logs.json"
      "target" = "cdu/amazon-cloudwatch-agent-logs.json"
    },
  ]

  cdu_netmap_file = try(length(local.cdu_params.netmap_file), 0) == 0 ? [] : [
    {
      "source" = "./${local.cdu_params.node_name}/${local.cdu_params.netmap_file}"
      "target" = "cdu/${local.cdu_params.node_name}/netmap_a.cfg"
    }
  ]

  cdu_users_file = try(length(local.cdu_params.users_file), 0) == 0 ? [] : [
    {
      "source" = "./${local.cdu_params.node_name}/${local.cdu_params.users_file}"
      "target" = "cdu/${local.cdu_params.node_name}/userfile_a.cfg"
    }
  ]

  cdu_config_files = flatten([local.cdu_required_files, local.cdu_netmap_file, local.cdu_users_file])

  cdu_extra_files = try(length(var.cdu_extra_files), 0) == 0 ? {
    tokens = []
    files  = []
  } : var.cdu_extra_files

  cdu_extra_files_content = [for extra_file in local.cdu_extra_files.files : "sudo su cdadmin -c \"aws s3 cp s3://${local.cdu_params.s3_bucket}/cdu/${local.cdu_params.node_name}/${extra_file.source} ${extra_file.target}\""]
}

locals {
  efs = {
    efs_id = local.use_efs ? (local.create_efs ? module.cdu_efs[0].efs.id : var.cdu_efs_specs.efs_id) : null
  }
}

locals {
  create_nlb        = try(length(var.cdu_lb_target_ports), 0) != 0 ? true : false
  create_r53_record = local.create_nlb && try(length(var.r53_zone_name), 0) != 0 ? true : false
}
