# This allows instance to be managed via SystemsManager
data "aws_iam_policy" "ssm_managed_instance_core_policy" {
  count = local.create_cdu_role ? 1 : 0

  name = "AmazonSSMManagedInstanceCore"
}

# This allows permissions to send data to CloudWatch for enhanced monitoring
data "aws_iam_policy" "cloudwatch_full_access_policy" {
  count = local.create_cdu_role ? 1 : 0

  name = "CloudWatchFullAccess"
}

# This allows permissions to access S3
data "aws_iam_policy" "s3_full_access_policy" {
  count = local.create_cdu_role ? 1 : 0

  name = "AmazonS3FullAccess"
}

data "aws_iam_policy_document" "cdu_node_assume_role" {
  count = local.create_cdu_role ? 1 : 0

  statement {
    sid = "AllowAssumeRoleToCDUNode"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cdu_node_role" {
  count = local.create_cdu_role ? 1 : 0

  name               = local.cdu_role_name
  description        = "This role is assumed by the EC2 instance to function as CDU node"
  assume_role_policy = data.aws_iam_policy_document.cdu_node_assume_role[count.index].json
  #permissions_boundary = "arn-for-permission-boundary"

  tags = var.tags
}

resource "aws_iam_instance_profile" "cdu_node_role" {
  count = local.create_cdu_role ? 1 : 0

  name = local.cdu_instance_profile
  role = aws_iam_role.cdu_node_role[0].name

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cdu_node_role" {
  for_each = local.create_cdu_role ? toset([
    data.aws_iam_policy.ssm_managed_instance_core_policy[0].arn,
    data.aws_iam_policy.s3_full_access_policy[0].arn,
    data.aws_iam_policy.cloudwatch_full_access_policy[0].arn,
  ]) : toset([])

  role       = aws_iam_role.cdu_node_role[0].name
  policy_arn = each.value
}

data "aws_iam_instance_profile" "cdu_node_role" {
  name = local.create_cdu_role ? aws_iam_instance_profile.cdu_node_role[0].name : var.cdu_host_specs.ec2_instance_profile
}
