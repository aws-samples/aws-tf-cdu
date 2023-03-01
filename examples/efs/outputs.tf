output "efs" {
  description = "Elastic File System info"
  value       = module.common_efs.efs
}

output "efs_ap" {
  description = "Elastic File System Access Points"
  value       = module.common_efs.efs_ap
}
