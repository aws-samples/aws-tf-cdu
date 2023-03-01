resource "aws_lb" "cdu_nlb" {
  # checkov:skip=CKV_AWS_150: out of scope
  # checkov:skip=CKV_AWS_91: NLB is pass-thru
  count = local.create_nlb ? 1 : 0

  name               = "${local.cdu_params.node_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnets.subnets.ids

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  ip_address_type = var.enable_dual_stack ? "dualstack" : "ipv4"

  #access_logs TODO

  tags = merge(
    {
      Name    = "${local.cdu_params.node_name}-nlb"
      Product = "C:D Unix"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "cdu_tg" {
  for_each             = { for cdu_target in var.cdu_lb_target_ports : cdu_target.purpose => cdu_target }
  name                 = "${local.cdu_params.node_name}-tg-${each.value.purpose}"
  target_type          = "instance"
  protocol             = each.value.protocol
  port                 = each.value.port
  vpc_id               = data.aws_vpc.vpc.id
  deregistration_delay = each.value.deregistration_delay
  preserve_client_ip   = each.value.preserve_client_ip
  stickiness {
    enabled = true
    type    = "source_ip"
  }
  health_check {
    enabled  = true
    protocol = each.value.hc_protocol
    port     = each.value.hc_port
    interval = each.value.hc_interval
    #timeout             = 10
    healthy_threshold   = each.value.hc_healthy_threshold
    unhealthy_threshold = each.value.hc_unhealthy_threshold
  }
  tags = merge(
    {
      Name    = "${local.cdu_params.node_name}-tg-${each.value.purpose}"
      Product = "C:D Unix"
    },
    var.tags
  )
}

resource "aws_autoscaling_group" "cdu_asg" {
  name                      = "${local.cdu_params.node_name}-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = data.aws_subnets.subnets.ids
  health_check_grace_period = 120
  health_check_type         = "EC2"
  target_group_arns         = [for tg in aws_lb_target_group.cdu_tg : tg.arn]
  launch_template {
    id      = aws_launch_template.cdu_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.cdu_params.node_name}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Product"
    value               = "C:D Unix"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
  depends_on = [
    aws_s3_object.required_file,
    module.cdu_efs #efs should be ready, before ASG comes in play
  ]
}

resource "aws_lb_listener" "cdu_listener" {
  # checkov:skip=CKV_AWS_2: N/A
  # checkov:skip=CKV_AWS_103: N/A
  for_each          = { for cdu_target in var.cdu_lb_target_ports : cdu_target.purpose => cdu_target }
  load_balancer_arn = aws_lb.cdu_nlb[0].arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cdu_tg[each.value.purpose].arn
  }
  tags = merge(
    {
      Name    = "${local.cdu_params.node_name}-listener-${each.value.purpose}"
      Product = "C:D Unix"
    },
    var.tags
  )
}

resource "aws_route53_record" "cdu_rec_ipv4" {
  count = local.create_r53_record ? 1 : 0

  zone_id = data.aws_route53_zone.pvt_zone[count.index].zone_id
  name    = "${lower(local.cdu_params.node_name)}.${data.aws_route53_zone.pvt_zone[count.index].name}"
  type    = "A"
  alias {
    name                   = aws_lb.cdu_nlb[0].dns_name
    zone_id                = aws_lb.cdu_nlb[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdu_rec_ipv6" {
  count = local.create_r53_record && var.enable_dual_stack ? 1 : 0

  zone_id = data.aws_route53_zone.pvt_zone[count.index].zone_id
  name    = "ipv6.${lower(local.cdu_params.node_name)}.${data.aws_route53_zone.pvt_zone[count.index].name}"
  type    = "AAAA"
  alias {
    name                   = aws_lb.cdu_nlb[0].dns_name
    zone_id                = aws_lb.cdu_nlb[0].zone_id
    evaluate_target_health = true
  }
}
