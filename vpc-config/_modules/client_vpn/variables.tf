variable "client_cidr_block" {
  type = string
}

variable "server_certificate_arn" {
  type = string
}

variable "client_certificate_arn" {
  type = string
}

variable "dns_servers" {
  type    = list(string)
  default = ["8.8.8.8"]
}

variable "vpc_cidr_block" {
  type = string

  # 추후 CIDR 충돌 방지를 위해 validation 추가 필요
  # validation {
  #   condition     = !(contains(cidrhost(var.client_cidr_block, 1), cidrsubnet(var.vpc_cidr_block, 0, 0)) || contains(cidrhost(var.vpc_cidr_block, 1), cidrsubnet(var.client_cidr_block, 0, 0)))
  #   error_message = "The client CIDR block must not overlap with the VPC CIDR block."
  # }
}
