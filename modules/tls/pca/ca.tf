resource "tls_private_key" "ca_key" {
  algorithm   = var.private_key_algorithm
  rsa_bits    = var.private_key_algorithm == "RSA" ? var.private_key_rsa_bits : null
  ecdsa_curve = var.private_key_algorithm == "ECDSA" ? var.private_key_ecdsa_curve : null
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem       = tls_private_key.ca_key.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = var.root_validity_days * 24

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "crl_signing"
  ]

  subject {
    common_name         = var.root_common_name    #CN
    organizational_unit = var.organizational_unit #OU
    organization        = var.organization        #O
    locality            = var.locality            #L
    province            = var.province            #ST
    country             = var.country             #C
  }

  set_authority_key_id = true
  set_subject_key_id   = true
}

# resource "local_sensitive_file" "ca_cert" {
#   content  = tls_self_signed_cert.ca_cert.cert_pem
#   filename = "${var.trust_folder}/ca-cert.cer"
# }

resource "aws_s3_object" "ca_cert" {
  for_each = toset(var.server_common_names)

  # checkov:skip=CKV_AWS_186: N/A
  bucket = var.s3_bucket
  key = join("", [
    "${var.bucket_prefix}/",
    upper(split(".", each.value)[0]),
  "/ca-cert.cer"])
  content = tls_self_signed_cert.ca_cert.cert_pem

  source_hash = md5(tls_self_signed_cert.ca_cert.cert_pem)
}
