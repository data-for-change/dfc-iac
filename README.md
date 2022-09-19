# Data For Change Infrastructure As Code

This repo contains Terraform configurations for managing Data For Change infrastructure as code.

Every commit to the repo will run terraform plan in GitHub actions, you can check the actions log for details.
To prevent destructive actions, apply the changes you have to run locally as described below.

## Running locally

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
