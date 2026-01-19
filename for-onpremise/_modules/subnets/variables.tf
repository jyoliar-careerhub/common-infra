variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_route_table_id" {
  type = string
}

variable "private_route_table_id" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `true`."
  type        = bool
  default     = true
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}
