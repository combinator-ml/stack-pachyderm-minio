variable "namespace" {
  description = "(Optional) The namespace to install the release into. Defaults to default"
  type        = string
  default     = "default"
}

variable "pachyderm_bucket_name" {
  description = "(Optional) the name of the bucket in minio to store Pachyderm data (must be bucket name compliant)"
  type        = string
  default     = "pachyderm-data"
}
