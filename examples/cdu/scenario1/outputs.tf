output "cdu_instance_profile" {
  description = "Instance Profile for the CDU instance"
  value       = module.cdu_ha.cdu_instance_profile
}

output "cdu_ami" {
  description = "AMI for the CDU instance"
  value       = module.cdu_ha.cdu_ami
}

output "cdu_kms" {
  description = "KMS Keys created"
  value       = module.cdu_ha.cdu_kms
}

output "cdu_security_group" {
  description = "Security Group for the CDU"
  value       = module.cdu_ha.cdu_security_group
}

output "cdu_nlb_dns" {
  description = "NLB DNS for C:D Unix"
  value       = module.cdu_ha.cdu_nlb_dns
}

output "cdu_cw_log_group" {
  description = "CloudWatch log group for C:D Unix"
  value       = module.cdu_ha.cdu_cw_log_group
}

output "cdu_r53_fqdn" {
  description = "Route 53 FQDN for C:D Unix"
  value       = module.cdu_ha.cdu_r53_fqdn
}

output "efs_id" {
  description = "Elastic File System info"
  value       = module.cdu_ha.efs_id
}

# output "efs_ap_id" {
#   description = "Elastic File System ids"
#   value       = module.cdu_ha.efs_ap_id
# }

output "cdu_efs_root" {
  description = "CDU root folder on EFS"
  value       = module.cdu_ha.cdu_efs_root
}
