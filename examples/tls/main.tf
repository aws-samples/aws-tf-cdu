#Use the following command to create the cert-passphrase in parameter store
#aws ssm put-parameter --name /tf-cdu-tls/examples/tls/cert_passphrase  --type SecureString --overwrite --value <changeme>
data "aws_ssm_parameter" "cert_passphrase" {
  name            = "/tf-cdu-tls/examples/tls/cert_passphrase"
  with_decryption = true
}

module "cdu_keycerts" {
  source = "../../modules/tls/pca"

  server_common_names = [
    "usldcduc01.cdu",
    "usldcduc02.cdu"
  ]

  trust_folder  = ".temp"
  s3_bucket     = var.s3_bucket
  bucket_prefix = "cdu"

  cert_passphrase = data.aws_ssm_parameter.cert_passphrase.value

  generate_server_encrypted_key_file = false
  generate_server_cert_file          = false
  generate_server_key_cert_file      = true
}
