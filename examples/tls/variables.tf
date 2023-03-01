/*---------------------------------------------------------
Private Certificate Authority Variable
---------------------------------------------------------*/
variable "s3_bucket" {
  description = "Amazon S3 bucket name where generated TLS artifacts are uploaded"
  type        = string
}
