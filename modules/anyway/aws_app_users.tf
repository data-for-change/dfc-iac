locals {
  prod_app_user_policies = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]
}

resource "aws_iam_user" "prod_app_user" {
  name = "anyway-prod-app-user"
}

resource "null_resource" "prod_app_user_keys_vault" {
    provisioner "local-exec" {
        command = "python3 vault/write_aws_access_keys.py ${aws_iam_user.prod_app_user.name} projects/anyway/prod/aws_prod_app_user"
    }
}

resource "aws_iam_user_policy_attachment" "prod_app_user_policy" {
  for_each = toset(local.prod_app_user_policies)
  user = aws_iam_user.prod_app_user.id
  policy_arn = each.key
}
