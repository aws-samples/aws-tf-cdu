resource "tls_private_key" "server_key" {
  for_each    = toset(var.server_common_names)
  algorithm   = var.private_key_algorithm
  rsa_bits    = var.private_key_algorithm == "RSA" ? var.private_key_rsa_bits : null
  ecdsa_curve = var.private_key_algorithm == "ECDSA" ? var.private_key_ecdsa_curve : null
}

resource "tls_cert_request" "server_csr" {
  for_each = toset(var.server_common_names)

  private_key_pem = tls_private_key.server_key[each.value].private_key_pem

  subject {
    common_name         = "${each.value}.${var.root_common_name}" #CN
    organizational_unit = var.organizational_unit                 #OU
    organization        = var.organization                        #O
    locality            = var.locality                            #L
    province            = var.province                            #ST
    country             = var.country                             #C
  }
}

resource "tls_locally_signed_cert" "server_cert" {
  for_each = toset(var.server_common_names)

  cert_request_pem   = tls_cert_request.server_csr[each.value].cert_request_pem
  ca_private_key_pem = tls_private_key.issuer_key.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.issuer_cert.cert_pem

  is_ca_certificate = false
  # Certificate expires after 365 days.
  validity_period_hours = var.server_validity_days * 24
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  set_subject_key_id = true
}

# resource "local_sensitive_file" "server_cert" {
#   for_each = var.generate_server_cert_file ? toset(var.server_common_names) : toset([])

#   content  = tls_locally_signed_cert.server_cert[each.value].cert_pem
#   filename = "${var.trust_folder}/${each.value}-cert.cer"
# }

resource "aws_s3_object" "server_cert" {
  for_each = var.generate_server_cert_file ? toset(var.server_common_names) : toset([])

  # checkov:skip=CKV_AWS_186: N/A
  bucket = var.s3_bucket
  key = join("", [
    "${var.bucket_prefix}/",
    upper(split(".", each.value)[0]),
  "/${each.value}-cert.cer"])
  content = tls_locally_signed_cert.server_cert[each.value].cert_pem

  source_hash = md5(tls_locally_signed_cert.server_cert[each.value].cert_pem)
}

#Verify Cert using following command
#openssl verify -CAfile .\ca-cert.cer -untrusted .\issuer-cert.cer -show_chain .\usldcduc01.cdu-cert.cer

resource "local_sensitive_file" "server_key" {
  for_each = toset(var.server_common_names)

  content  = tls_private_key.server_key[each.value].private_key_pem
  filename = "${var.trust_folder}/${each.value}-key-temp.pem"

  provisioner "local-exec" {
    command = "openssl pkcs8 -topk8 -passout pass:${var.cert_passphrase} -out ${var.trust_folder}/${each.value}-key.pem -in ${var.trust_folder}/${each.value}-key-temp.pem"
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Remove-Item ${self.filename}" : "rm -f ${self.filename}"
  }
}

data "local_sensitive_file" "pkcs8" {
  for_each = toset(var.server_common_names)
  filename = "${var.trust_folder}/${each.value}-key.pem"

  depends_on = [
    local_sensitive_file.server_key
  ]
}

resource "aws_s3_object" "server_keycert" {
  for_each = var.generate_server_key_cert_file ? toset(var.server_common_names) : toset([])

  # checkov:skip=CKV_AWS_186: N/A
  bucket = var.s3_bucket
  key = join("", [
    "${var.bucket_prefix}/",
    upper(split(".", each.value)[0]),
  "/${each.value}-keycert.txt"])
  content = "${data.local_sensitive_file.pkcs8[each.value].content}${tls_locally_signed_cert.server_cert[each.value].cert_pem}"

  source_hash = md5(tls_locally_signed_cert.server_cert[each.value].cert_pem)
}

resource "null_resource" "clean_pkcs8" {
  for_each = var.generate_server_encrypted_key_file ? toset([]) : toset(var.server_common_names)

  triggers = {
    hash = md5(data.local_sensitive_file.pkcs8[each.value].content)
  }

  provisioner "local-exec" {
    when        = create
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Remove-Item ${data.local_sensitive_file.pkcs8[each.value].filename}" : "rm -f ${data.local_sensitive_file.pkcs8[each.value].filename}"
  }
}

#Encrypt the key
#openssl pkcs8 -topk8 -in .\usldcduc01.cdu-key.pem -out .\usldcduc01.cdu-key-enc.pem
