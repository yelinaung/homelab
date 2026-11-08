// Proxmox Variables
variable "pve_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "pve_username" {
  description = "Proxmox username"
  type        = string
  sensitive   = true
}

variable "pve_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "ubuntu_release" {
  description = "Ubuntu release to build the golden template for (key of local.templates)"
  type        = string
  default     = "24.04"
}

// Base template (Terraform, vm_template_ubuntu_*.tf) → golden template VMID.
locals {
  templates = {
    "24.04" = { golden_vm_id = 9001 }
    "26.04" = { golden_vm_id = 9003 }
  }
  template = local.templates[var.ubuntu_release]
}

variable "pve_node" {
  description = "Proxmox node name"
  type        = string
  default     = "homelab3"
}
