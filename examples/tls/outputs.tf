output "ca_cert_file" {
  description = "CA Certificate File"
  value       = module.cdu_keycerts.ca_cert_file
}

output "issuer_cert_file" {
  description = "Issuer Certificate File"
  value       = module.cdu_keycerts.issuer_cert_file
}

output "server_key_cert_file" {
  description = "Server Key-Certificate File"
  value       = module.cdu_keycerts.server_key_cert_file
}
