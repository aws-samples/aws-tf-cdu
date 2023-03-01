#data "aws_caller_identity" "current" {}

data "aws_kms_key" "ebs_cmk" {
  count = local.create_ebs_kms ? 1 : 0

  key_id = local.ebs_kms_alias

  depends_on = [
    module.cdu_kms
  ]
}

data "aws_kms_key" "logs_cmk" {
  count = local.create_logs_kms ? 1 : 0

  key_id = local.logs_kms_alias

  depends_on = [
    module.cdu_kms
  ]
}

data "aws_kms_key" "ssm_cmk" {
  count = local.create_ssm_kms ? 1 : 0

  key_id = local.ssm_kms_alias

  depends_on = [
    module.cdu_kms
  ]
}

data "aws_vpc" "vpc" {
  tags = var.vpc_tags
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = var.subnet_tags
}

data "aws_route53_zone" "pvt_zone" {
  count = local.create_r53_record ? 1 : 0

  name         = var.r53_zone_name
  vpc_id       = data.aws_vpc.vpc.id
  private_zone = true
}

data "aws_ami" "cdu_ami" {
  count = try(length(var.cdu_host_specs.image_id), 0) == 0 ? 1 : 0

  most_recent = true

  owners = ["amazon", "self"]
  #executable_users = ["self"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] #i386 | x86_64 | arm64
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"] #io1 | io2 | gp2 | gp3 | sc1 | st1 | standard
  }
}
