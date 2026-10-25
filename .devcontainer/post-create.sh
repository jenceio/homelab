#!/usr/bin/env bash
# Runs once after the devcontainer is created (DevPod or VS Code).
set -euo pipefail

mise trust --yes
mise install uv
mise install

pre-commit install --install-hooks
ansible-galaxy collection install -r ansible/requirements.yml

if [[ ! -s "${SOPS_AGE_KEY_FILE}" ]]; then
  echo "WARNING: no age key at ${SOPS_AGE_KEY_FILE} - SOPS decryption will not work." >&2
  echo "         Create one on the HOST (see README, 'Secrets') and rebuild the workspace." >&2
fi
