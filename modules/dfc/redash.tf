resource "null_resource" "redash_secrets" {
  lifecycle {
    ignore_changes = all
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOF
# this should only run once!
#      COOKIE_SECRET=$(pwgen -1s 32)
#      SECRET_KEY=$(pwgen -1s 32)
#      POSTGRES_PASSWORD=$(pwgen -1s 32)
#      REDASH_DATABASE_URL="postgresql://postgres:$POSTGRES_PASSWORD@postgres/postgres"
#      vault kv put -mount=kv projects/k8s/redash/secret \
#        "cookie_secret=$COOKIE_SECRET" \
#        "secret_key=$SECRET_KEY" \
#        "postgres_password=$POSTGRES_PASSWORD" \
#        "redash_database_url=$REDASH_DATABASE_URL"
    EOF
  }
}
