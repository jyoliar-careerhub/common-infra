variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}

variable "cluster_security_group_ids" {
  type = list(string)
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_size" {
  type = number
}

variable "instance_types" {
  type = list(string)
}

variable "ami_type" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "update_config" {
  type    = number
  default = 1
}
