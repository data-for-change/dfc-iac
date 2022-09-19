terraform {
  backend "pg" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.23.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
