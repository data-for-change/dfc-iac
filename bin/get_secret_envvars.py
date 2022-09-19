#!/usr/bin/env python3
import os
import json
import functools
import subprocess


@functools.lru_cache(None)
def vault_read(path):
    return json.loads(subprocess.check_output(['vault', 'read', f'kv/data/{path}', '-format=json']))['data']['data']


def main():
    if not os.path.exists(".kubeconfig"):
        with open(".kubeconfig", "w") as f:
            f.write(vault_read("admin/k8s-main-kubeconfig")['KUBECONFIG'])
    values = {
        'AWS_ACCESS_KEY_ID': vault_read('projects/iac/aws')['access-key-id'],
        'AWS_SECRET_ACCESS_KEY': vault_read('projects/iac/aws')['secret-access-key'],
        'TF_VAR_cloudflare_api_token': vault_read('projects/iac/cloudflare')['api-token'],
        'TF_VAR_infrastructure_root_domain': vault_read('projects/iac/dns')['infrastructure-root-domain'],
        'KUBECONFIG': '.kubeconfig',
        'KUBE_CONFIG_PATH': '.kubeconfig',
    }
    envvars = []
    for k, v in values.items():
        envvars.append(f'export {k}="{v}"')
    print('\n'.join(envvars))
    

if __name__ == "__main__":
    main()
