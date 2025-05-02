variable "name" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "policy_arn" {
  type = string
}
