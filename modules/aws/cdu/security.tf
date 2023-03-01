resource "aws_security_group" "cdu_sg" {
  # checkov:skip=CKV2_AWS_5: SG is attached in the resource module
  # checkov:skip=CKV_AWS_23: N/A
  name        = "${var.project}-${local.cdu_params.node_name}-cdu-sg"
  description = "Secure inbound/outbound traffic for C:D Unix Server"
  vpc_id      = data.aws_vpc.vpc.id

  tags = merge(
    {
      Name    = "${var.project}-${local.cdu_params.node_name}-cdu-sg"
      Product = "C:D Unix"
    },
    var.tags
  )
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "ingress_cdu_sg" {
  for_each = try(length(var.cdu_ingress.ingress_ports), 0) != 0 && try(length(var.cdu_ingress.source_cidrs), 0) != 0 ? toset(var.cdu_ingress.ingress_ports) : toset([])

  description       = "Allow inbound traffic from ${join(",", var.cdu_ingress.source_cidrs)} on ${each.value}"
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = var.cdu_ingress.source_cidrs
  security_group_id = aws_security_group.cdu_sg.id
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "egress_cdu_sg" {
  description       = "Allow egress to all from CDU"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cdu_sg.id
}

data "aws_security_group" "cdu_sg" {
  id = aws_security_group.cdu_sg.id
}

data "aws_security_group" "cdu_efs" {
  count = local.use_efs ? 1 : 0

  id   = local.create_efs_sg ? module.cdu_efs[0].efs.sg_id : null
  tags = local.create_efs_sg ? null : var.cdu_efs_specs.security_group_tags
}

resource "aws_security_group_rule" "allow_cdu_ingress_to_efs" {
  count = local.use_efs ? 1 : 0

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  description              = "Allow CDU node access to the EFS"
  security_group_id        = data.aws_security_group.cdu_efs[0].id
  source_security_group_id = data.aws_security_group.cdu_sg.id
}
