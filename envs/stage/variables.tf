variable "env" {
  description = "The deployment environment"
  type        = string
  default     = "staging"
}

variable "account_id" {
  description = "AWS account id"
  type        = string
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

variable "backend_certificate_arn" {
  description = "AWS ACM backend domain ARN"
  type        = string
}

variable "admin_certificate_arn" {
  description = "AWS ACM backend domain ARN"
  type        = string
}

variable "client_certificate_arn" {
  description = "AWS ACM backend domain ARN"
  type        = string
}

variable "db_username" {
  description = "DB username"
  type        = string
}

variable "db_password" {
  description = "DB password"
  type        = string
}

variable "admin_domain" {
  type = string
}

variable "client_domain" {
  type = string
}