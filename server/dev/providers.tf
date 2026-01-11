terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      env = var.env
    }
  }

  region = var.region
}
