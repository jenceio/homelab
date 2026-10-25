# Credentials come from the environment, injected by `sops exec-env secrets.sops.yaml`:
#   PROXMOX_VE_ENDPOINT, PROXMOX_VE_API_TOKEN
provider "proxmox" {
  insecure = var.proxmox_insecure

  # Only used by the few operations the Proxmox API cannot do (e.g. snippets).
  # DevPod forwards your local SSH agent into the container.
  ssh {
    agent    = true
    username = "root"
  }
}
