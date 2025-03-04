variable "env" {
  type        = string
}

variable "bucket_name" {
  type        = string
}

variable "index_document" {
  type        = string
  default     = "index.html"
}

variable "error_document" {
  type        = string
  default     = "index.html"
}

variable "aws_region" {
  type        = string
}