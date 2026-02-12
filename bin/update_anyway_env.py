#!/usr/bin/env python3
import sys
import json


KEYS_MAP = {
    "ANYWAY_IMAGE": "image",
    "NGINX_IMAGE": "nginxImage",
    "REPORTS_IMAGE": "anywayReportsImage",
    "ETL_NGINX_IMAGE": "etlNginxImage",
    "AIRFLOW_IMAGE": "airflowImage",
    "SAFETY_DATA_CLIENT_IMAGE": "safetyDataClientImage",
}


def main(images, apps_dir=None):
    if not apps_dir:
        apps_dir = 'apps'
    images = json.loads(images)
    with open(f'{apps_dir}/anyway/.env', 'r') as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        line = line.strip()
        if line:
            key = line.split('=')[0]
            if key in KEYS_MAP and KEYS_MAP[key] in images:
                line = '{}={}'.format(key, images[KEYS_MAP[key]]).replace('docker.pkg.github.com', 'ghcr.io')
            new_lines.append(line)
    with open(f'{apps_dir}/anyway/.env', 'w') as f:
        f.write('\n'.join(new_lines))


if __name__ == '__main__':
    main(*sys.argv[1:])
