variable "name" {
  type        = string
  description = "The name of the VM"
}

variable "node_name" {
  type        = string
  description = "The name of the Proxmox node"
}

variable "vm_id" {
  type        = number
  description = "The ID of the VM"
}

variable "memory_dedicated" {
  type        = number
  description = "The amount of dedicated memory for the VM (in MB)"
}

variable "disk_size" {
  type        = number
  description = "The size of the disk (in GB)"
}
variable "vm_disk_datastore_id" {
  type        = string
  description = "The datastore ID where the main VM disk will be stored (e.g., local-lvm)"
}

variable "disk_datastore_id" {
  type        = string
  description = "The datastore ID where the ISO installation media is stored (e.g., homelab1-data)"
}

variable "iso_path" {
  type        = string
  description = "The path to the ISO file"
}

variable "mac_address" {
  default     = ""
  type        = string
  description = "The MAC address of the VM"
}

variable "cpu_cores" {
  type        = number
  description = "The number of CPU cores for the VM"
}

variable "tags" {
  default     = ["terraform"]
  type        = list(string)
  description = "The tags for the VM"
}

variable "iso_disk_size" {
  type        = number
  default     = 2
  description = "The size of the ISO disk in GB (default: 2)"
}
