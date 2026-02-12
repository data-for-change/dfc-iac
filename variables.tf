variable "cloudflare_api_token" {
  type = string
  sensitive = true
}

variable "infrastructure_root_domain" {
  type = string
  sensitive = true
}

variable "aws_default_ssh_key_name" {
  type = string
  sensitive = true
}
