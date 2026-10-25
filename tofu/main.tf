# Base cloud image, downloaded by Proxmox itself.
# content_type "import" requires Proxmox VE 8.4+.
resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.proxmox_node
  url          = var.cloud_image_url
  file_name    = basename(var.cloud_image_url)
}

resource "proxmox_virtual_environment_vm" "k8s" {
  for_each = var.nodes

  name        = each.key
  node_name   = var.proxmox_node
  vm_id       = each.value.vm_id
  description = "Managed by OpenTofu"
  tags        = ["tofu", "k8s", each.value.role]
  on_boot     = true

  # Debian genericcloud images do not ship qemu-guest-agent; Ansible installs it.
  # Flip to true after the first Ansible run if you want IP reporting in the UI.
  agent {
    enabled = false
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_virtual_environment_download_file.cloud_image.id
    interface    = "virtio0"
    size         = each.value.disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  operating_system {
    type = "l26"
  }

  # Debian cloud images expect a serial console.
  serial_device {}

  initialization {
    datastore_id = var.vm_datastore

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.cidr_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.vm_user
      keys     = var.ssh_public_keys
    }
  }
}
