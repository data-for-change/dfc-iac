#!/usr/bin/env python3
import sys
import json


KEYS_MAP = {
    "ANYWAY_IMAGE": "image",
    "NGINX_IMAGE": "nginxImage",
}


def main(images):
    images = json.loads(images)
    with open('apps/anyway/.env', 'r') as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        line = line.strip()
        if line:
            key = line.split('=')[0]
            if key in KEYS_MAP and KEYS_MAP[key] in images:
                line = '{}={}'.format(key, images[KEYS_MAP[key]])
            new_lines.append(line)
    with open('apps/anyway/.env', 'w') as f:
        f.write('\n'.join(new_lines))


if __name__ == '__main__':
    main(sys.argv[1])
