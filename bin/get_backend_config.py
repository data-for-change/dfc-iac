#!/usr/bin/env python3
import json
import subprocess


def main():
    data = json.loads(subprocess.check_output(['vault', 'read', 'kv/data/projects/iac/terraform', '-format=json']))['data']['data']
    print(data['backend-config'])
    

if __name__ == "__main__":
    main()
