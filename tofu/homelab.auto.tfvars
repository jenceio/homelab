# Non-secret settings. Secrets live in secrets.sops.yaml.
proxmox_node = "pve"

gateway     = "192.168.1.1"
cidr_prefix = 24
dns_servers = ["192.168.1.1"]

ssh_public_keys = [
  # "ssh-ed25519 AAAA... you@laptop",
]

nodes = {
  "k3s-server-1" = { vm_id = 201, role = "server", ip = "192.168.1.51", cores = 2, memory = 4096, disk_size = 32 }
  "k3s-agent-1"  = { vm_id = 211, role = "agent", ip = "192.168.1.61", cores = 4, memory = 8192, disk_size = 64 }
  "k3s-agent-2"  = { vm_id = 212, role = "agent", ip = "192.168.1.62", cores = 4, memory = 8192, disk_size = 64 }
}
