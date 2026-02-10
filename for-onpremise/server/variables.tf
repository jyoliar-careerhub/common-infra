variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "server_domain" {
  type = string
}

variable "k8s_api_domain" {
  type = string
}

variable "additional_public_key" {
  description = "Additional SSH public key to add to authorized_keys"
  type        = string
  default     = ""
}

variable "worker_ingress_domain" {
  description = "Domain for worker ingress NLB (e.g., *.jyo-liar.com)"
  type        = string
  default     = "*.jyo-liar.com"
}
