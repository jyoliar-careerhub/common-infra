variable "name" {
  type = string
}

variable "engine_version" {
  type = string
}


variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "volume_size" {
  type = number
}

variable "admin_principal_arns" {
  type    = list(string)
  default = []
}
