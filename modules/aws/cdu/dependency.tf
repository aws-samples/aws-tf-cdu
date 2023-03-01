module "cdu_kms" {
  source = "github.com/aws-samples/aws-tf-kms//modules/aws/kms?ref=v1.0.0"
  count  = local.create_kms ? 1 : 0

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  kms_alias_prefix = var.project
  kms_admin_roles  = var.kms_admin_roles
  kms_usage_roles  = [local.cdu_role_name]

  enable_kms_ebs  = local.create_ebs_kms
  enable_kms_logs = local.create_logs_kms
  enable_kms_ssm  = local.create_ssm_kms

  depends_on = [
    data.aws_iam_instance_profile.cdu_node_role
  ]
}

module "cdu_efs" {
  source = "github.com/aws-samples/aws-tf-efs//modules/aws/efs?ref=v1.0.0"
  count  = local.create_efs ? 1 : 0

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  #Make sure that target VPC is identified uniquely via these tags
  vpc_tags = var.vpc_tags

  #Make sure that target subnets are tagged correctly
  subnet_tags = var.subnet_tags

  security_group_tags = var.cdu_efs_specs.efs_id != null ? null : var.cdu_efs_specs.security_group_tags

  #create kms only if EFS is being created
  kms_alias       = var.cdu_efs_specs.kms_alias
  kms_admin_roles = var.kms_admin_roles

  efs_name = "cdu"
  #if efs_id is null, EFS will be created
  efs_id           = var.cdu_efs_specs.efs_id
  encrypted        = var.cdu_efs_specs.encrypted
  performance_mode = "generalPurpose"
  transition_to_ia = "AFTER_7_DAYS"
  efs_tags = {
    "BackupPlan" = "EVERY-DAY"
  }

  efs_access_point_specs = []
}
