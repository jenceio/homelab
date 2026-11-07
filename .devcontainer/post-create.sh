#!/usr/bin/env bash
# Runs once after the devcontainer is created (DevPod or VS Code).
set -euo pipefail

# DevPod runs this hook via `su`, which resets PATH and drops the Dockerfile's
# ENV PATH, so mise and its shims (pre-commit, ansible-galaxy, ...) are not found.
export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH}"

# Pull in the host's git config (aliases, defaults) without making it the
# container's global file, so DevPod/VS Code can still write ~/.gitconfig.
if [[ -f "${HOME}/.config/git-host/config" ]]; then
  git config --global --replace-all include.path "${HOME}/.config/git-host/config" "git-host"
fi

mise trust --yes
mise install uv
mise install

pre-commit install --install-hooks
ansible-galaxy collection install -r ansible/requirements.yml

if [[ ! -s "${SOPS_AGE_KEY_FILE}" ]]; then
  echo "WARNING: no age key at ${SOPS_AGE_KEY_FILE} - SOPS decryption will not work." >&2
  echo "         Create one on the HOST (see README, 'Secrets') and rebuild the workspace." >&2
fi
