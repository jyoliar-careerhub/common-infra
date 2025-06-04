provider "aws" {
  default_tags {
    tags = {
      env = var.env
    }
  }

  region = var.region
}
