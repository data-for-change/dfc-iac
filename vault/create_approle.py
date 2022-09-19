import sys
import json
import subprocess


def main(role_name, policy_name):
    p = subprocess.run(['vault', 'auth', 'enable', 'approle'], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    if p.returncode == 0:
        print('AppRole auth method enabled')
    else:
        if p.stderr.decode().strip().endswith("path is already in use at approle/"):
            print("Approle auth method was already enabled")
        else:
            raise Exception(p.stderr.decode())
    subprocess.check_call([
        "vault", "write", f"auth/approle/role/{role_name}",
        f'"token_policies="{policy_name}"',
        'token_ttl=1h', 'token_max_ttl=4h'
    ])
    role_id = json.loads(subprocess.check_output([
        "vault", "read", "-format=json", f"auth/approle/role/{role_name}/role-id"
    ]))["data"]["role_id"]
    secret_id = json.loads(subprocess.check_output([
        "vault", "write", "-format=json", "-f", f"auth/approle/role/{role_name}/secret-id"
    ]))["data"]["secret_id"]
    print(f"role_id: {role_id}")
    print(f"secret_id: {secret_id}")


if __name__ == "__main__":
    main(*sys.argv[1:])
