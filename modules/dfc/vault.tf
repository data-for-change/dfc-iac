resource "null_resource" "vault_policy" {
  for_each = toset(var.vault_policies)
  provisioner "local-exec" {
    command = "python3 vault/create_policy.py ${each.value}"
  }
}

resource "null_resource" "vault_approle" {
  for_each = toset(var.vault_approles)
  provisioner "local-exec" {
    command = "python3 vault/create_approle.py ${each.value}"
  }
}