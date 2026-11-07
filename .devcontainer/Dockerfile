FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# OS-level dependencies only; all project tooling comes from .mise.toml.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       python3 python3-venv openssh-client rsync jq unzip \
    && rm -rf /var/lib/apt/lists/*

USER root

ENV MISE_DATA_DIR=/root/.local/share/mise \
    PATH=/root/.local/bin:/root/.local/share/mise/shims:${PATH}

# Pre-create dirs so the named volumes mounted there inherit root ownership.
RUN mkdir -p ~/.local/share/mise ~/.cache/pre-commit ~/.config/sops/age \
    && curl -fsSL https://mise.run | sh \
    && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
