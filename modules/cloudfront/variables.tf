variable "env" {
  type        = string
}

variable "acm_certificate_arn" {
  type        = string
}

variable "index_document" {
  type        = string
  default     = "index.html"
}

variable "s3_bucket_regional_domain_name" {
    type = string
}

variable "aliases" {
  type        = list(string)
  default     = []
}