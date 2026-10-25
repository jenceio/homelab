#!/usr/bin/env bash
# Fail if a Kubernetes Secret manifest lives outside a *.sops.yaml file.
set -euo pipefail

status=0
for file in "$@"; do
  if grep -qE '^kind:[[:space:]]*Secret[[:space:]]*$' "$file"; then
    echo "PLAINTEXT SECRET: $file  ->  rename to *.sops.yaml and encrypt with sops" >&2
    status=1
  fi
done
exit "$status"
