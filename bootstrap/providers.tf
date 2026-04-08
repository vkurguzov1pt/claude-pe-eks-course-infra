terraform {
  # anything 1.14.0 or newer
  required_version = ">=1.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # pessimistic constraint. Allows 6.39.0, 6.40.0, 6.99.0, but not 7.0.0
      version = "~> 6.39"
    }
    # gives Terraform the ability to work with TLS/SSL certificates and keys
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
