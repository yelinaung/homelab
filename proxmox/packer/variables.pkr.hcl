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

variable "pve_node" {
  description = "Proxmox node name"
  type        = string
  default     = "homelab3"
}
