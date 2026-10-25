variable "state_passphrase" {
  description = "Passphrase for OpenTofu state encryption (min 16 chars). Set via TF_VAR_state_passphrase."
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification (self-signed Proxmox certificate)."
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Name of the Proxmox node to create VMs on."
  type        = string
}

variable "image_datastore" {
  description = "Datastore that holds downloaded cloud images (needs 'import' content type)."
  type        = string
  default     = "local"
}

variable "vm_datastore" {
  description = "Datastore for VM disks and cloud-init drives."
  type        = string
  default     = "local-lvm"
}

variable "cloud_image_url" {
  description = "Cloud image used as the base disk of every VM."
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "gateway" {
  type = string
}

variable "cidr_prefix" {
  description = "Prefix length of the LAN, e.g. 24."
  type        = number
  default     = 24
}

variable "dns_servers" {
  type = list(string)
}

variable "vm_user" {
  description = "Default user created by cloud-init (Ansible connects as this user)."
  type        = string
  default     = "debian"
}

variable "ssh_public_keys" {
  description = "SSH public keys authorised for vm_user. Public keys are not secrets."
  type        = list(string)
}

variable "nodes" {
  description = "Kubernetes node VMs keyed by hostname."
  type = map(object({
    vm_id     = number
    role      = string # "server" or "agent"
    ip        = string
    cores     = number
    memory    = number # MiB
    disk_size = number # GiB
  }))

  validation {
    condition     = alltrue([for n in values(var.nodes) : contains(["server", "agent"], n.role)])
    error_message = "Each node role must be either \"server\" or \"agent\"."
  }
}
