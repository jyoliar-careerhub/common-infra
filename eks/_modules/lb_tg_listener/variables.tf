variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "load_balancer_arn" {
  type = string
}

variable "lb_sg_id" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "target_protocol" {
  type = string
}

variable "target_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "target_group_tags" {
  type    = map(string)
  default = {}
}

variable "access_allow_cidr_blocks" {
  type = list(string)
}
