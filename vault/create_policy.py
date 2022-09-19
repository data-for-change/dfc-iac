import os
import sys
import subprocess


def main(policy_name):
    policy_filename = f"vault/policies/{policy_name}.hcl"
    assert os.path.exists(policy_filename)
    subprocess.check_call([
        "vault", "policy", "write", policy_name, policy_filename
    ])


if __name__ == "__main__":
    main(*sys.argv[1:])
