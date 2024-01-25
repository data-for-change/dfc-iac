# Data For Change Infrastructure As Code

## Prerequisites

* Python 3
* [Vault CLI](https://developer.hashicorp.com/vault/downloads)

Install Python Dependencies:

```
python3 -m pip install -r requirements.txt
```

Create a directory for secret files:

```
sudo mkdir -p /etc/dfc
sudo chown $USER -R /etc/dfc
```

## Apps

The apps are defined using Docker Compose with some additional configurations under `apps/`

Anyway app is continuously deployed on any change to `apps/anyway`, the other apps need to be deployed manually.

To manage the apps you need to get a Vault TOKEN, access vault at https://vault.dataforchange.gov.il and login.
Once logged-in, click on your name in the top right corner and select "Copy token".
Set the Token in an env var:

```
export VAULT_TOKEN=<paste token here>
```

You might need to get a new token occasionally, if you get an error message about an invalid token, just repeat the above steps.

Now you can run the apps management script to manage the apps, following are some examples:

```
# Run Docker Compose commands
bin/apps.py compose APP_NAME COMMAND
# for example:
bin/apps.py compose anyway ps
bin/apps.py compose anyway logs -f anyway-main

# SSH to the server
bin/apps.py ssh

# Run a command on the server
bin/apps.py ssh docker ps

# Deploy an app
bin/apps.py deploy_app APP_NAME
```

## Terraform

Prerequisites:

* [Terraform CLI](https://www.terraform.io/downloads.html)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

### Running locally

Initialize (should only be done once):

```
terraform init "-backend-config=$(bin/get_backend_config.py)"
```

Set secret envvars:

```
eval "$(bin/get_secret_envvars.py)"
```

Check the plan:

```
terraform plan
```

Apply:

```
terraform apply
```
