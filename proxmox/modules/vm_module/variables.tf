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
variable "disk_datastore_id_disk" {
  type        = string
  description = "The datastore ID for the disk"
}

variable "disk_datastore_id" {
  type        = string
  description = "The datastore ID for the disk"
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
