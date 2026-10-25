#!/usr/bin/env bash
# Fail if any *.sops.yaml file passed in is not SOPS-encrypted.
set -euo pipefail

status=0
for file in "$@"; do
  if ! grep -qE '^sops:' "$file" || ! grep -q 'ENC\[AES256_GCM,' "$file"; then
    echo "NOT ENCRYPTED: $file  ->  run: sops --encrypt --in-place $file" >&2
    status=1
  fi
done
exit "$status"
