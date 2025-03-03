variable "env" {
  description = "The deployment environment"
  type        = string
  default     = "production"
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}
