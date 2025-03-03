variable "env" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "db_subnet_ids" {
  type        = list(string)
}

variable "security_group_ids" {
  type        = list(string)
}

variable "engine" {
  type        = string
}

variable "engine_version" {
  type        = string
}

variable "instance_class" {
  type        = string
}

variable "allocated_storage" {
  type        = number
}

variable "username" {
  type        = string
}

variable "password" {
  type        = string
  sensitive   = true
}

variable "db_name" {
  type        = string
}