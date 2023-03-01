/*---------------------------------------------------------
Private Certificate Authority Variable
---------------------------------------------------------*/
variable "private_key_algorithm" {
  description = "The name of the algorithm to use for private keys. Must be one of: RSA, ECDSA, or ED25519."
  type        = string
  default     = "RSA"
  validation {
    condition     = contains(["RSA", "ECDSA", "ED25519"], var.private_key_algorithm)
    error_message = "Error: private_key_algorithm Valid values: RSA, ECDSA, or ED25519."
  }
}

variable "private_key_rsa_bits" {
  description = "The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA."
  type        = number
  default     = 2048
}

variable "private_key_ecdsa_curve" {
  description = "The name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521."
  type        = string
  default     = "P224"
  validation {
    condition     = contains(["P224", "P256", "P384", "P521"], var.private_key_ecdsa_curve)
    error_message = "Error: private_key_ecdsa_curve Valid values: P224, P256, P384 or P521."
  }
}


variable "root_validity_days" {
  description = "The number of days that the Root CA will remain valid. Minimum 365."
  type        = number
  default     = 3650
  validation {
    condition     = var.root_validity_days >= 365
    error_message = "Error: root_validity_days minimum value is 365."
  }
}

variable "issuer_validity_days" {
  description = "The number of days that the Issuer CA will remain valid. Minimum 275"
  type        = number
  default     = 2750
  validation {
    condition     = var.issuer_validity_days >= 275
    error_message = "Error: issuer_validity_days minimum value is 275."
  }
}

variable "server_validity_days" {
  description = "The number of days that the Server Cert will remain valid. Minimum 180"
  type        = number
  default     = 365
  validation {
    condition     = var.server_validity_days >= 180
    error_message = "Error: server_validity_days minimum value is 180."
  }
}

variable "root_common_name" {
  description = "Root Common Name i.e. CN"
  type        = string
  default     = "samples.aws"
}

variable "issuer_common_name" {
  description = "Issuer Common Name i.e. CN"
  type        = string
  default     = "issuer.samples.aws"
}

variable "organizational_unit" {
  description = "Organizational Unit i.e. OU"
  type        = string
  default     = "samples"
}

variable "organization" {
  description = "Organization i.e. O"
  type        = string
  default     = "aws"
}

variable "locality" {
  description = "Locality i.e. L"
  type        = string
  default     = "LOS ANGELES"
}

variable "province" {
  description = "Province i.e. ST"
  type        = string
  default     = "CA"
}

variable "country" {
  description = "Country i.e. C"
  type        = string
  default     = "US"
}

variable "trust_folder" {
  description = "Folder where output files are generated"
  type        = string
  default     = ".temp"
}

variable "cert_passphrase" {
  description = "Passphrase to encrypt the TLS keys/certs"
  type        = string
  sensitive   = true
}

variable "server_common_names" {
  description = "List of Server Common Names. `root_common_name` will be added to this name"
  type        = list(string)
  default     = []
}

variable "generate_server_cert_file" {
  description = "Generate Server Cert File"
  type        = bool
  default     = false
}

variable "generate_server_encrypted_key_file" {
  description = "Generate Server Encrypted Key File"
  type        = bool
  default     = false
}

variable "generate_server_key_cert_file" {
  description = "Generate Server Key Cert File"
  type        = bool
  default     = false
}

variable "s3_bucket" {
  description = "Amazon S3 bucket name where generated TLS artifacts are uploaded"
  type        = string
}

variable "bucket_prefix" {
  description = "Amazon S3 bucket prefix where TLS artifacts are uploaded"
  type        = string
}
