resource "tls_private_key" "issuer_key" {
  algorithm   = var.private_key_algorithm
  rsa_bits    = var.private_key_algorithm == "RSA" ? var.private_key_rsa_bits : null
  ecdsa_curve = var.private_key_algorithm == "ECDSA" ? var.private_key_ecdsa_curve : null
}

resource "tls_cert_request" "issuer_csr" {
  private_key_pem = tls_private_key.issuer_key.private_key_pem

  subject {
    common_name         = var.issuer_common_name  #CN
    organizational_unit = var.organizational_unit #OU
    organization        = var.organization        #O
    locality            = var.locality            #L
    province            = var.province            #ST
    country             = var.country             #C
  }
}

resource "tls_locally_signed_cert" "issuer_cert" {
  cert_request_pem   = tls_cert_request.issuer_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  is_ca_certificate     = true
  validity_period_hours = var.issuer_validity_days * 24
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]

  set_subject_key_id = true
}

# resource "local_sensitive_file" "issuer_cert" {
#   content  = tls_locally_signed_cert.issuer_cert.cert_pem
#   filename = "${var.trust_folder}/issuer-cert.cer"
# }

resource "aws_s3_object" "issuer_cert" {
  for_each = toset(var.server_common_names)

  # checkov:skip=CKV_AWS_186: N/A
  bucket = var.s3_bucket
  key = join("", [
    "${var.bucket_prefix}/",
    upper(split(".", each.value)[0]),
  "/issuer-cert.cer"])
  content = tls_locally_signed_cert.issuer_cert.cert_pem

  source_hash = md5(tls_locally_signed_cert.issuer_cert.cert_pem)
}

#Verify Cert using following command
#openssl verify -CAfile .\ca-cert.cer -show_chain .\issuer-cert.cer
