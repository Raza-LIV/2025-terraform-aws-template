variable "env" {
  description = "The deployment environment"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for login"
  type        = string
}

variable "access_key" {
  description = "AWS IAM access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS IAM secret key"
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "AWS ACM domain ARN"
  type        = string
}