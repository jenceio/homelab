output "nodes" {
  description = "Hostname -> role/IP, mirror this in ansible/inventory/hosts.yaml."
  value = {
    for name, node in var.nodes : name => {
      role = node.role
      ip   = node.ip
    }
  }
}
