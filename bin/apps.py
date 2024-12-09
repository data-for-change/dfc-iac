#!/usr/bin/env python3
import os
import sys
import json
import subprocess
from ruamel import yaml
from functools import lru_cache
from tempfile import TemporaryDirectory


VAULT_ADDR = os.environ.get('VAULT_ADDR', 'https://vault.dataforchange.org.il')
VAULT_TOKEN = os.environ.get('VAULT_TOKEN')
ETC_DFC_DOCKER = '/etc/dfc/docker' if os.environ.get("CI") != "true" else '/tmp/dfc/docker'


@lru_cache()
def get_vault_kv_path(path):
    assert VAULT_TOKEN, "VAULT_TOKEN env var is required, see README for how to get it"
    return json.loads(subprocess.check_output([
        'vault', 'kv', 'get', '-format=json', f'kv/{path}'
    ], env={
        **os.environ,
        'VAULT_ADDR': VAULT_ADDR,
        'VAULT_TOKEN': VAULT_TOKEN,
    }))['data']['data']


def ssh_init():
    if not os.path.exists(f'{ETC_DFC_DOCKER}/id_ed25519') or not os.path.exists(f'{ETC_DFC_DOCKER}/hostname'):
        data = get_vault_kv_path('projects/iac/docker-server')
        hostname = data['hostname']
        id_ed25519 = data['id_ed25519']
        os.makedirs(ETC_DFC_DOCKER, exist_ok=True)
        with open(f'{ETC_DFC_DOCKER}/hostname', 'w') as f:
            f.write(hostname)
        with open(f'{ETC_DFC_DOCKER}/id_ed25519', 'w') as f:
            f.write(id_ed25519)
        subprocess.check_call(['chmod', '600', f'{ETC_DFC_DOCKER}/id_ed25519'])
    else:
        with open(f'{ETC_DFC_DOCKER}/hostname') as f:
            hostname = f.read().strip()
    return hostname


def ssh(*args, check_output=False):
    hostname = ssh_init()
    cmd = [
        'ssh', '-t', '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/dev/null', '-o', 'LogLevel=ERROR', '-o', 'IdentitiesOnly=yes',
        '-i', f'{ETC_DFC_DOCKER}/id_ed25519', f'ubuntu@{hostname}', *args
    ]
    if check_output:
        return subprocess.check_output(cmd).decode('utf-8')
    else:
        subprocess.check_call(cmd)


def get_secret_value(value, key=None, app_name=None):
    if isinstance(value, dict):
        assert key and app_name
        type_ = value.get('type') or 'template'
        assert type_ == 'template'
        template_filename = value.get('template_filename') or f'{key}.template'
        with open(f'apps/{app_name}/{template_filename}') as f:
            template = f.read()
        for k, v in value.get('values').items():
            v = get_secret_value(v)
            template = template.replace(f'~{k}~', v)
        return template
    elif value.startswith('vault:'):
        _, path, key = value.split(":")
        return get_vault_kv_path(path)[key]
    elif value.startswith('server:'):
        _, path = value.split(":")
        return ssh(f'sudo cat {path}', check_output=True).strip()
    else:
        return value


def is_server_old_file_changed(src, dst):
    assert dst.startswith('~/apps/.new.')
    old = dst.replace('~/apps/.new.', '~/apps/')
    if ssh(f'if [ -e {old} ]; then echo "1"; else echo "0"; fi', check_output=True).strip() == "1":
        old_contents = ssh(f'sudo cat {old}', check_output=True)
        with open(src) as f:
            new_contents = f.read()
        return old_contents != new_contents
    else:
        return True


def scp(src, dst, stats=None):
    print(f'scp {src} {dst}')
    if stats and is_server_old_file_changed(src, dst):
        stats['all_changed_files'].add(dst)
    hostname = ssh_init()
    subprocess.check_call([
        'scp', '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/dev/null', '-o', 'LogLevel=ERROR', '-o', 'IdentitiesOnly=yes',
        '-i', f'{ETC_DFC_DOCKER}/id_ed25519', src, f'ubuntu@{hostname}:{dst}'
    ])


def copy_secrets(app_conf, app_name, stats):
    if 'x-secrets' in app_conf:
        ssh(f'mkdir -p ~/apps/.new.{app_name}/secrets')
        with TemporaryDirectory() as tmp_dir:
            all_file_names = set()
            for file_name, value in app_conf['x-secrets'].get('files', {}).items():
                all_file_names.add(file_name)
                value = get_secret_value(value, file_name, app_name)
                with open(os.path.join(tmp_dir, file_name), 'w') as f:
                    f.write(value)
            for file_name, env_values in app_conf['x-secrets'].get('env_files', {}).items():
                file_name = f'{file_name}.env'
                all_file_names.add(file_name)
                with open(os.path.join(tmp_dir, file_name), 'w') as f:
                    for key, value in env_values.items():
                        value = get_secret_value(value, key, app_name)
                        f.write(f'{key}="{value}"\n')
            for file_name in all_file_names:
                scp(os.path.join(tmp_dir, file_name), f'~/apps/.new.{app_name}/secrets/{file_name}', stats)


def copy_files(app_conf, app_name, stats):
    for src, file_conf in app_conf.get('x-files', {}).items():
        dst = file_conf.get('target') or src
        ssh(f'mkdir -p ~/apps/.new.{app_name}/{os.path.dirname(dst)}')
        scp(f'apps/{app_name}/{src}', f'~/apps/.new.{app_name}/{dst}', stats)


def deploy_cronjob(service_name, service, app_name):
    print(f'Deploying cronjob {service_name}')
    schedule = service['x-cronjob']['schedule']
    cronline = f'{schedule} ubuntu cd ~/apps/{app_name} && docker compose run --rm {service_name}'
    ssh(f'''
        sudo rm -f /etc/cron.d/{app_name}-{service_name}
        echo "{cronline}" | sudo tee /etc/cron.d/{app_name}-{service_name}
    ''')


def deploy_app(app_name, *args):
    skip_deploy = '--skip-deploy' in args
    assert os.path.exists(f'./apps/{app_name}/compose.yaml')
    with open(f'./apps/{app_name}/compose.yaml') as f:
        app_conf = yaml.safe_load(f)
    ssh(f'rm -rf ~/apps/.new.{app_name}')
    stats = {
        'all_changed_files': set()
    }
    copy_secrets(app_conf, app_name, stats)
    copy_files(app_conf, app_name, stats)
    ssh(f'mkdir -p ~/apps/.new.{app_name}')
    scp(f'./apps/{app_name}/compose.yaml', f'~/apps/.new.{app_name}/compose.yaml')
    ssh(f'''
        [ -e ~/apps/.old.{app_name} ] && sudo rm -rf ~/apps/.old.{app_name}
        [ -e ~/apps/{app_name} ] && sudo mv ~/apps/{app_name} ~/apps/.old.{app_name}
        sudo mv ~/apps/.new.{app_name} ~/apps/{app_name}
    ''')
    if not skip_deploy:
        for line in app_conf.get('x-pre-deploy', []):
            print('Running x-pre-deploy:', line)
            ssh(f'cd ~/apps/{app_name} && {line}')
        start_services = set()
        for service_name, service in app_conf['services'].items():
            if service.get('x-cronjob'):
                deploy_cronjob(service_name, service, app_name)
            else:
                start_services.add(service_name)
        ssh(f'''
            cd ~/apps/{app_name}
            docker compose up -d {' '.join(start_services)}
        ''')
        for on_file_change in app_conf.get('x-on-file-change', []):
            if not isinstance(on_file_change, dict):
                on_file_change = {'*': on_file_change}
            for file_name, line in on_file_change.items():
                run = file_name == '*' and len(stats['all_changed_files']) > 0
                if not run:
                    if not file_name.startswith('/'):
                        file_name = f'~/apps/.new.{app_name}/{file_name}'
                    run = file_name in stats['all_changed_files']
                if run:
                    print('Triggering x-on-file-change for', file_name, ':' ,line)
                    ssh(f'cd ~/apps/{app_name} && {line}')


def deploy_all_apps():
    for app_name in os.listdir('./apps'):
        deploy_app(app_name)


def compose(app_name, *args):
    ssh('docker', 'compose', '--project-directory', f'~/apps/{app_name}', *args)


def create_selenium_data_folder():
    ssh('mkdir -p /tmp/selenium-tempdata && sudo chown 1200:1201 /tmp/selenium-tempdata')


def main(cmd, *args):
    res = globals()[cmd](*args)
    if res is None:
        print("OK")
    else:
        print(res)


if __name__ == '__main__':
    main(*sys.argv[1:])
