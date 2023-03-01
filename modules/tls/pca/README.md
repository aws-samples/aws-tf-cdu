<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.3.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.56.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.56.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.ca_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.issuer_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.server_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.server_keycert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [local_sensitive_file.server_key](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/sensitive_file) | resource |
| [null_resource.clean_pkcs8](https://registry.terraform.io/providers/hashicorp/null/3.1.1/docs/resources/resource) | resource |
| [tls_cert_request.issuer_csr](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_cert_request.server_csr](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.issuer_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.server_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.issuer_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.server_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Amazon S3 bucket prefix where TLS artifacts are uploaded | `string` | n/a | yes |
| <a name="input_cert_passphrase"></a> [cert\_passphrase](#input\_cert\_passphrase) | Passphrase to encrypt the TLS keys/certs | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Amazon S3 bucket name where generated TLS artifacts are uploaded | `string` | n/a | yes |
| <a name="input_country"></a> [country](#input\_country) | Country i.e. C | `string` | `"US"` | no |
| <a name="input_generate_server_cert_file"></a> [generate\_server\_cert\_file](#input\_generate\_server\_cert\_file) | Generate Server Cert File | `bool` | `false` | no |
| <a name="input_generate_server_encrypted_key_file"></a> [generate\_server\_encrypted\_key\_file](#input\_generate\_server\_encrypted\_key\_file) | Generate Server Encrypted Key File | `bool` | `false` | no |
| <a name="input_generate_server_key_cert_file"></a> [generate\_server\_key\_cert\_file](#input\_generate\_server\_key\_cert\_file) | Generate Server Key Cert File | `bool` | `false` | no |
| <a name="input_issuer_common_name"></a> [issuer\_common\_name](#input\_issuer\_common\_name) | Issuer Common Name i.e. CN | `string` | `"issuer.samples.aws"` | no |
| <a name="input_issuer_validity_days"></a> [issuer\_validity\_days](#input\_issuer\_validity\_days) | The number of days that the Issuer CA will remain valid. Minimum 275 | `number` | `2750` | no |
| <a name="input_locality"></a> [locality](#input\_locality) | Locality i.e. L | `string` | `"LOS ANGELES"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Organization i.e. O | `string` | `"aws"` | no |
| <a name="input_organizational_unit"></a> [organizational\_unit](#input\_organizational\_unit) | Organizational Unit i.e. OU | `string` | `"samples"` | no |
| <a name="input_private_key_algorithm"></a> [private\_key\_algorithm](#input\_private\_key\_algorithm) | The name of the algorithm to use for private keys. Must be one of: RSA, ECDSA, or ED25519. | `string` | `"RSA"` | no |
| <a name="input_private_key_ecdsa_curve"></a> [private\_key\_ecdsa\_curve](#input\_private\_key\_ecdsa\_curve) | The name of the elliptic curve to use. Should only be used if var.private\_key\_algorithm is ECDSA. Must be one of P224, P256, P384 or P521. | `string` | `"P224"` | no |
| <a name="input_private_key_rsa_bits"></a> [private\_key\_rsa\_bits](#input\_private\_key\_rsa\_bits) | The size of the generated RSA key in bits. Should only be used if var.private\_key\_algorithm is RSA. | `number` | `2048` | no |
| <a name="input_province"></a> [province](#input\_province) | Province i.e. ST | `string` | `"CA"` | no |
| <a name="input_root_common_name"></a> [root\_common\_name](#input\_root\_common\_name) | Root Common Name i.e. CN | `string` | `"samples.aws"` | no |
| <a name="input_root_validity_days"></a> [root\_validity\_days](#input\_root\_validity\_days) | The number of days that the Root CA will remain valid. Minimum 365. | `number` | `3650` | no |
| <a name="input_server_common_names"></a> [server\_common\_names](#input\_server\_common\_names) | List of Server Common Names. `root_common_name` will be added to this name | `list(string)` | `[]` | no |
| <a name="input_server_validity_days"></a> [server\_validity\_days](#input\_server\_validity\_days) | The number of days that the Server Cert will remain valid. Minimum 180 | `number` | `365` | no |
| <a name="input_trust_folder"></a> [trust\_folder](#input\_trust\_folder) | Folder where output files are generated | `string` | `".temp"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_cert_file"></a> [ca\_cert\_file](#output\_ca\_cert\_file) | CA Certificate File |
| <a name="output_issuer_cert_file"></a> [issuer\_cert\_file](#output\_issuer\_cert\_file) | Issuer Certificate File |
| <a name="output_server_cert_file"></a> [server\_cert\_file](#output\_server\_cert\_file) | Server Certificate File |
| <a name="output_server_key_cert_file"></a> [server\_key\_cert\_file](#output\_server\_key\_cert\_file) | Server Key-Certificate File |
<!-- END_TF_DOCS -->
