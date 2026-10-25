terraform {
  required_version = ">= 1.10.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.80"
    }
  }

  # OpenTofu native state encryption: state and plan files are AES-GCM encrypted
  # with a key derived from TF_VAR_state_passphrase (stored in secrets.sops.yaml).
  # State is still gitignored; to share it, point a remote backend (S3/R2/MinIO)
  # here - it stays encrypted at rest.
  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }

    state {
      method   = method.aes_gcm.main
      enforced = true
    }

    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}
