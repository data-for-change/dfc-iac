variable "infrastructure_root_domain" {
  type = string
  sensitive = true
}

variable "name_prefix" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "subnet_cidr" {
  type = string
  default = "172.31.32.0/20"
}

variable "security_group_id" {
  type = string
  default = ""
}

variable "vault_policies" {
  type = list(string)
  default = [
    "readonly"
  ]
}

variable "vault_approles" {
  type = list(string)
  default = [
    "terraform_readonly"
  ]
}

variable "aws_default_ssh_key_name" {
  type = string
  default = null
}
