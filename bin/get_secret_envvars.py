#!/usr/bin/env python3
import os
import json
import functools
import subprocess

from ruamel import yaml


@functools.lru_cache(None)
def vault_read(path):
    return json.loads(subprocess.check_output(['vault', 'read', f'kv/data/{path}', '-format=json']))['data']['data']


def main():
    if not os.path.exists(".kubeconfig"):
        kubeconfig = yaml.safe_load(vault_read("admin/k8s-main-kubeconfig")['KUBECONFIG'])
        kubeconfig['users'][0]['user']['exec']['env'] = [
            {'name': 'AWS_STS_REGIONAL_ENDPOINTS', 'value': 'regional'},
        ]
        with open(".kubeconfig", "w") as f:
            yaml.safe_dump(kubeconfig, f)
    values = {
        'AWS_ACCESS_KEY_ID': vault_read('projects/iac/aws')['access-key-id'],
        'AWS_SECRET_ACCESS_KEY': vault_read('projects/iac/aws')['secret-access-key'],
        'TF_VAR_cloudflare_api_token': vault_read('projects/iac/cloudflare')['api-token'],
        'TF_VAR_infrastructure_root_domain': vault_read('projects/iac/dns')['infrastructure-root-domain'],
        'KUBECONFIG': '.kubeconfig',
        'KUBE_CONFIG_PATH': '.kubeconfig',
        'TF_VAR_aws_default_ssh_key_name': vault_read('projects/iac/aws')['default-ssh-key-name'],
    }
    envvars = []
    for k, v in values.items():
        envvars.append(f'export {k}="{v}"')
    print('\n'.join(envvars))
    

if __name__ == "__main__":
    main()
