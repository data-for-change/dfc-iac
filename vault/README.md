# Vault Infrastructure As Code

Due to the sensitive nature of Vault we manage it using scripts in this directory.

Terraform runs the scripts using local exec provisioners defined in `modules/dfc/vault.tf`

## Policies

Policies are defined under policies/ directory and created using `create_policy.py` script.

## App Roles

App roles are defined under `approles/` directory and created using `create_approle.py` script.

The script outputs a file with the role and secret ids at `.approle-ROLE_NAME.json`, you should save
save the result in the relevant place where they will be used (e.g. GitHub actions secret) and
delete the file afterwards.
