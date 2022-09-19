import sys
import json
import subprocess


def main(role_name, policy_name):
    res = json.loads(subprocess.check_output(["vault", "auth", "list", "-format=json"]))
    if 'approle/' not in res:
        subprocess.check_call(['vault', 'auth', 'enable', 'approle'])
        res = json.loads(subprocess.check_output(["vault", "auth", "list", "-format=json"]))
    approle_accessor = res['approle/']['accessor']
    print(f'approle_accessor: {approle_accessor}')
    subprocess.check_call([
        "vault", "write", "identity/entity",
        f'name=approle_{role_name}', f'policies={policy_name}',
    ])
    entity_id = json.loads(subprocess.check_output([
        "vault", "read", "-format=json", f"identity/entity/name/approle_{role_name}"
    ]))["data"]["id"]
    print(f'entity_id: {entity_id}')
    subprocess.check_call([
        "vault", "write", f"auth/approle/role/{role_name}", 'token_ttl=1h', 'token_max_ttl=4h'
    ])
    role_id = json.loads(subprocess.check_output([
        "vault", "read", "-format=json", f"auth/approle/role/{role_name}/role-id"
    ]))["data"]["role_id"]
    print(f'role_id: {role_id}')
    subprocess.check_call([
        "vault", "write", "identity/entity-alias",
        f'name={role_id}', f'canonical_id={entity_id}', f'mount_accessor={approle_accessor}',
    ])
    secret_id = json.loads(subprocess.check_output([
        "vault", "write", "-format=json", "-f", f"auth/approle/role/{role_name}/secret-id"
    ]))["data"]["secret_id"]
    print(f"secret_id: {secret_id}")


if __name__ == "__main__":
    main(*sys.argv[1:])
