output "cdu_kms" {
  description = "Outputs from KMS module"
  value       = [for kms in module.cdu_kms : kms.key_aliases]
}

output "cdu_instance_profile" {
  description = "Instance Profile for the CDU instance"
  value       = data.aws_iam_instance_profile.cdu_node_role.name
}

output "cdu_security_group" {
  description = "Security Group for the CDU instance"
  value       = data.aws_security_group.cdu_sg.name
}

output "cdu_ami" {
  description = "AMI for C:D Unix Instance"
  value       = local.image_id
}

output "cdu_launch_template_id" {
  description = "Id for the Launch Template for C:D Unix"
  value       = aws_launch_template.cdu_lt.id
}

output "cdu_launch_template_version" {
  description = "Version of the Launch Template for C:D Unix"
  value       = aws_launch_template.cdu_lt.latest_version
}

output "cdu_target_groups" {
  description = "Target Groups for C:D Unix"
  value       = [for tg in aws_lb_target_group.cdu_tg : tg.arn]
}

output "cdu_autoscaling_group" {
  description = "Autoscaling group for C:D Unix"
  value       = aws_autoscaling_group.cdu_asg.name
}

output "cdu_nlb_dns" {
  description = "NLB DNS for C:D Unix"
  value       = local.create_r53_record ? aws_lb.cdu_nlb[0].dns_name : ""
}

output "cdu_cw_log_group" {
  description = "CloudWatch log group for C:D Unix"
  value       = aws_cloudwatch_log_group.cdu_logs.name
}

output "cdu_r53_fqdn" {
  description = "Route 53 FQDN for C:D Unix"
  value       = flatten([[for cdu_rec in aws_route53_record.cdu_rec_ipv4 : cdu_rec.fqdn], [for cdu_rec in aws_route53_record.cdu_rec_ipv6 : cdu_rec.fqdn]])
}

output "efs_id" {
  description = "Elastic File System info"
  value       = local.efs.efs_id
}

output "cdu_efs_root" {
  description = "CDU root folder on EFS/EBS"
  value       = local.use_efs ? "${local.efs_root}/${local.cdu_params.node_name}" : local.cdu_params.node_name
}
