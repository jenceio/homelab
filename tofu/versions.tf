terraform {
  required_version = ">= 1.10.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.80"
    }
  }

  # State lives in a Cloudflare R2 bucket (S3-compatible), off the homelab it describes.
  # Credentials and the account-specific endpoint come from secrets.sops.yaml via
  # `sops exec-env`: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ENDPOINT_URL_S3.
  # The encryption block below still applies, so R2 only ever stores ciphertext.
  backend "s3" {
    bucket       = "homelab-tofu-state"
    key          = "proxmox/terraform.tfstate"
    region       = "auto"
    use_lockfile = true

    # R2 is not AWS: skip the AWS-only checks and use path-style URLs.
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

  # OpenTofu native state encryption: state and plan files are AES-GCM encrypted
  # with a key derived from TF_VAR_state_passphrase (stored in secrets.sops.yaml).
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
