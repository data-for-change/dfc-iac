# Vault Infrastructure As Code

Due to the sensitive nature of Vault we manage it using scripts in this directory.

## Policies

Policies are defined under policies/ directory and created using `create_policy.py` script.

Policies are applied via Terraform as defined in modules/dfc/vault.tf

## App Roles

App roles are defined under `approles/` directory and created using `create_approle.py` script.

App roles are applied via Terraform as defined in modules/dfc/vault.tf

The script outputs a file with the role and secret ids at `.approle-ROLE_NAME.json`, you should save
save the result in the relevant place where they will be used (e.g. GitHub actions secret) and
delete the file afterwards.

## Users

To create a user:

```
python3 vault/create_user.py <user_name>
```

The script outputs the user credentials which you should send to the relevant user.

You can then add the user to the relevant group via the web UI.

