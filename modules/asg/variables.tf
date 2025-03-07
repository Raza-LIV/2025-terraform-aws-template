variable "env" {
  description = "The deployment environment"
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable lb_arn {
  type        = string
}

variable target_group_arn {
  type = any
}

variable access_key {
  type = string
}

variable secret_key {
  type = string
}

variable region {
  type = string
}

variable account_id {
  type = string
}
