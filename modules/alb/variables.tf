variable "env" {
  description = "The deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC in which ALB and Target Group going to be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs applied to ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN certificate of HTTPS which is used via ALB"
  type        = string
}
