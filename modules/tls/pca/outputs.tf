output "ca_cert_file" {
  description = "CA Certificate File"
  value       = [for s3_object in aws_s3_object.ca_cert : s3_object.key]
}

output "issuer_cert_file" {
  description = "Issuer Certificate File"
  value       = [for s3_object in aws_s3_object.issuer_cert : s3_object.key]
}

output "server_cert_file" {
  description = "Server Certificate File"
  value       = [for s3_object in aws_s3_object.server_cert : s3_object.key]
}

output "server_key_cert_file" {
  description = "Server Key-Certificate File"
  value       = [for s3_object in aws_s3_object.server_keycert : s3_object.key]
}
