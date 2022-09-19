import sys
import json
import subprocess


def main(user_name, target_path):
    res = json.loads(subprocess.check_output([
        "aws", "iam", "create-access-key",
        "--user-name", user_name
    ]))
    access_key_id = res["AccessKey"]["AccessKeyId"]
    secret_access_key = res["AccessKey"]["SecretAccessKey"]
    subprocess.check_call([
        "vault", "kv", "put", f'kv/{target_path}',
        f"access_key_id={access_key_id}",
        f"secret_access_key={secret_access_key}"
    ])
    print("OK")


if __name__ == "__main__":
    main(*sys.argv[1:])
