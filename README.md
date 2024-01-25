# Data For Change Infrastructure As Code

## Apps

Apps are deployed from `apps/` directory using docker compose.

### Install for local management

Prerequisites:

* Python 3
* AWS CLI
* Vault CLI
* Env vars:
  * `VAULT_ADDR`
  * `VAULT_TOKEN`

Install Python Dependencies:

```
python3 -m pip install -r requirements.txt
```

### Deploy

```
bin/apps.py deploy_app APP_NAME
```

### Docker Compose Management

```
bin/apps.py compose APP_NAME COMMAND
```

for example:

```
bin/apps.py compose anyway ps
bin/apps.py compose anyway logs -f
bin/apps.py compose anyway logs -f anyway-main
```

### Server Management

SSH to the server:

```
bin/apps.py ssh
bin/apps.py ssh docker ps
```

## Terraform

Every commit to the repo will run terraform plan in GitHub actions, you can check the actions log for details.
To prevent destructive actions, apply the changes you have to run locally as described below.

### Running locally

Prerequisites:

* Python3
* [vault binary](https://www.vaultproject.io/downloads)
* Prerequisites for [dfc-k8s cluster connect](https://github.com/data-for-change/dfc-k8s/blob/main/docs/Cluster%20Connect.md)

Install Python environment

```
python3 -m venv venv
venv/bin/pip install -r requirements.txt
```

Activate Python environment

```
. venv/bin/activate
```

Set vault credentials:

```
export VAULT_ADDR=
export VAULT_TOKEN=
```

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
