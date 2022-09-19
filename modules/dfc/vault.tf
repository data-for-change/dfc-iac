locals {
  vault_policies = [
    "readonly"
  ]
  vault_approles = [
    "terraform_readonly"
  ]
}

resource "null_resource" "vault_policy" {
  for_each = toset(local.vault_policies)
  provisioner "local-exec" {
    command = "python3 vault/create_policy.py ${each.value}"
  }
}

resource "null_resource" "vault_approle" {
  for_each = toset(local.vault_approles)
  provisioner "local-exec" {
    command = "python3 vault/create_approle.py ${each.value}"
  }
}