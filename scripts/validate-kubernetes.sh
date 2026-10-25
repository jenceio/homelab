#!/usr/bin/env bash
# Offline validation of everything under kubernetes/:
#   1. every manifest against Kubernetes + Flux CRD + community CRD schemas
#   2. every kustomization builds, and its output validates too
# Requires: kustomize, kubeconform, curl, tar.
set -euo pipefail

root="kubernetes"
schema_dir="${TMPDIR:-/tmp}/flux-crd-schemas"

if [[ ! -d "${schema_dir}/master-standalone-strict" ]]; then
  echo "==> Downloading Flux CRD schemas"
  mkdir -p "${schema_dir}/master-standalone-strict"
  curl -fsSL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz \
    | tar zxf - -C "${schema_dir}/master-standalone-strict"
fi

kubeconform_args=(
  -strict
  -summary
  -ignore-missing-schemas
  -skip Secret
  -schema-location default
  -schema-location "${schema_dir}"
  -schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"
)

echo "==> Validating manifests"
find "${root}" -type f -name '*.yaml' \
  ! -name 'kustomization.yaml' \
  ! -path '*/flux-system/*' \
  ! -name '*.sops.yaml' \
  -print0 | xargs -0 kubeconform "${kubeconform_args[@]}"

echo "==> Validating kustomize overlays"
find "${root}" -type f -name 'kustomization.yaml' ! -path '*/flux-system/*' -print0 |
  while IFS= read -r -d '' file; do
    dir="$(dirname "${file}")"
    echo "--- ${dir}"
    kustomize build "${dir}" | kubeconform "${kubeconform_args[@]}"
  done
