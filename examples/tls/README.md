# Scenario : Create IBM C:D Unix server `keycert` file(s) (optional)
This is an example Terraform script, which creates the IBM C:D Unix server `keycert` file required for testing the solution. This creates a Private Certificate Authority (PCA) and server `keycert` file(s) that are also uploaded to the `s3_bucket`.

**This can be used for testing purpose only.**

## Prerequisites
- Terraform backend provider and state locking providers are identified and bootstrapped.
    - A [bootstrap](../bootstrap) module/example is provided that provisions Amazon S3 for Terraform state storage and Amazon DynamoDB for Terraform state locking.
- List of server common names are identified (e.g. "usldcduc01.cdu", "usldcduc02.cdu") for which `keycert` files are generated.
- An Amazon S3 bucket (`s3_bucket`), used for storing generated the IBM C:D Unix server `keycert` file exists and identified by name.
    - *The example is using the same Amazon S3 bucket that is used for Terraform state. e.g. aws-tf-cdu-dev-terraform-state-bucket*
- The private key encryption password is stored in the AWS System Manager Parameter Store.
    - The generated server `keycert` file has encrypted private key which is protected by a password. This password must be stored in the AWS System Manager Parameter Store with a fixed key "/tf-cdu-tls/examples/tls/cert_passphrase"
    - It is encouraged to create the secret key via AWS CLI rather than Terraform. For example:
        ```bash
        aws ssm put-parameter --name /tf-cdu-tls/examples/tls/cert_passphrase --value changeme --type SecureString --overwrite
        ```

## Outcome
- The server `keycert` file(s) are generated and uploaded to `s3_bucket`
- The Certificate Authority (CA) certificate file is generated and uploaded to `s3_bucket`
- The issuer certificate file is generated and uploaded to `s3_bucket`

## Execution

- cd to `examples/tls` folder.
- Modify the `backend "S3"` section in `provider.tf` with correct values for `region`, `bucket`, `dynamodb_table`, and `key`.
    - Use provided values as guidance.
- Modify `terraform.tfvars` to your requirements.
    - Use provided values as guidance.
- Modify `main.tf` to your requirements.
    - Validate the list of server common names for which `keycert` files will be generated.
    - Use provided values as guidance.
- Make sure you are using the correct AWS Profile that has permission to provision the target resources.
    - `aws sts get-caller-identity`
- Execute `terraform init` to initialize Terraform.
- Execute `terraform plan` and verify the changes.
- Execute `terraform apply` and approve the changes to provision the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.3.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.56.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.56.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cdu_keycerts"></a> [cdu\_keycerts](#module\_cdu\_keycerts) | ../../modules/tls/pca | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Amazon S3 bucket name where generated TLS artifacts are uploaded | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_cert_file"></a> [ca\_cert\_file](#output\_ca\_cert\_file) | CA Certificate File |
| <a name="output_issuer_cert_file"></a> [issuer\_cert\_file](#output\_issuer\_cert\_file) | Issuer Certificate File |
| <a name="output_server_key_cert_file"></a> [server\_key\_cert\_file](#output\_server\_key\_cert\_file) | Server Key-Certificate File |
<!-- END_TF_DOCS -->
