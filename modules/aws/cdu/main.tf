resource "aws_cloudwatch_log_group" "cdu_logs" {
  # checkov:skip=CKV_AWS_158: Encrypted by choice
  name              = local.cdu_params.cw_log_group
  retention_in_days = 7
  kms_key_id        = local.cdu_encrypted ? data.aws_kms_key.logs_cmk[0].arn : null

  tags = merge(
    {
      Name = "${var.project}-cdu-logs"
    },
    var.tags
  )
}

resource "aws_ssm_parameter" "cert_password" {
  count = try(length(var.cdu_secrets.cert_password), 0) != 0 ? 1 : 0

  name      = "${local.cdu_params.secret_key_prefix}/${local.cdu_params.node_name}/cert_password"
  type      = "SecureString"
  value     = var.cdu_secrets.cert_password
  key_id    = local.cdu_encrypted ? data.aws_kms_key.ssm_cmk[0].arn : null
  overwrite = true

  tags = merge(
    {
      Name    = "${var.project}-${var.env_name}-cdu-${local.cdu_params.node_name}-cert_password"
      Product = "C:D Unix"
      #Node    = each.value.node
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to the value, as it might have changed outside of TF
      value
    ]
  }
}

resource "aws_ssm_parameter" "keystore_password" {
  count = try(length(var.cdu_secrets.keystore_password), 0) != 0 ? 1 : 0

  name      = "${local.cdu_params.secret_key_prefix}/${local.cdu_params.node_name}/keystore_password"
  type      = "SecureString"
  value     = var.cdu_secrets.keystore_password
  key_id    = local.cdu_encrypted ? data.aws_kms_key.ssm_cmk[0].arn : null
  overwrite = true

  tags = merge(
    {
      Name    = "${var.project}-${var.env_name}-cdu-${local.cdu_params.node_name}-keystore_password"
      Product = "C:D Unix"
      #Node    = each.value.node
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to the value, as it might have changed outside of TF
      value
    ]
  }
}

resource "aws_launch_template" "cdu_lt" {
  name                   = "${local.cdu_params.node_name}-lt"
  description            = "Use this Launch Template for C:D Unix Compute Environment. Verify User Data script for the Node Name and EFS Instance."
  update_default_version = true
  image_id               = local.image_id
  instance_type          = var.cdu_host_specs.instance_type

  #ASG will terminate the stopped instance
  #instance_initiated_shutdown_behavior = "terminate"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = local.cdu_encrypted
      kms_key_id            = local.cdu_encrypted ? data.aws_kms_key.ebs_cmk[0].arn : null
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_protocol_ipv6          = var.enable_dual_stack ? "enabled" : "disabled"
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = var.enable_dual_stack
    enable_resource_name_dns_a_record    = true
    hostname_type                        = var.enable_dual_stack ? "resource-name" : "ip-name"
  }

  monitoring {
    enabled = var.cdu_host_specs.enable_detailed_monitoring
  }

  iam_instance_profile {
    arn = data.aws_iam_instance_profile.cdu_node_role.arn
  }

  key_name               = try(var.cdu_host_specs.ssh_key_name, "") != "" ? var.cdu_host_specs.ssh_key_name : null
  vpc_security_group_ids = [data.aws_security_group.cdu_sg.id]

  user_data = base64encode(
    templatefile(
      "${path.module}/files/cdu-user-data.tpl",
      merge(
        {
          "efs_dns"    = local.use_efs ? "--efs-dns ${local.efs.efs_id}" : ""
          "efs_root"   = local.use_efs ? "--efs-root ${local.efs_root}" : ""
          "aws_region" = var.region
        },
        local.cdu_params
      )
    )
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name       = local.cdu_params.node_name
        Product    = "C:D Unix"
        BackupPlan = try(var.cdu_host_specs.backup_plan, "") != "" ? var.cdu_host_specs.backup_plan : null
      },
      var.tags
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name    = local.cdu_params.node_name
        Product = "C:D Unix"
      },
      var.tags
    )
  }
  tags = merge(
    {
      Name    = "${local.cdu_params.node_name}-lt"
      Product = "C:D Unix"
    },
    var.tags
  )

  depends_on = [
    aws_cloudwatch_log_group.cdu_logs
  ]
}

resource "aws_s3_object" "required_file" {
  # checkov:skip=CKV_AWS_186: N/A
  for_each = { for cdu_config_file in local.cdu_config_files : cdu_config_file.target => cdu_config_file }
  bucket   = local.cdu_params.s3_bucket
  key      = each.value.target
  source   = each.value.source

  source_hash = filemd5(each.value.source)
  #common files, do not tag
  #tags        = var.tags
}

resource "aws_s3_object" "cdu_extra_file" {
  # checkov:skip=CKV_AWS_186: N/A
  for_each = try(length(var.cdu_extra_files.files), 0) != 0 ? { for cdu_extra_file in var.cdu_extra_files.files : cdu_extra_file.source => cdu_extra_file } : {}
  bucket   = local.cdu_params.s3_bucket
  key      = "cdu/${local.cdu_params.node_name}/${each.value.source}"
  content = templatefile(
    "./${local.cdu_params.node_name}/${each.value.source}",
    { for cdu_extra_file_token in var.cdu_extra_files.tokens : cdu_extra_file_token.name => cdu_extra_file_token.value }
  )

  source_hash = filemd5("./${local.cdu_params.node_name}/${each.value.source}")
  tags        = var.tags
}

resource "aws_s3_object" "cdu_extra_files" {
  count = try(length(var.cdu_extra_files), 0) != 0 ? 1 : 0

  # checkov:skip=CKV_AWS_186: N/A
  bucket  = local.cdu_params.s3_bucket
  key     = "cdu/${local.cdu_params.node_name}/cdu_extra_files.sh"
  content = join("\n", local.cdu_extra_files_content)

  source_hash = md5(join("\n", local.cdu_extra_files_content))
}
