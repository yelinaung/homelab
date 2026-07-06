variable "name" {
  type        = string
  description = "The name of the VM"
}

variable "node_name" {
  type        = string
  description = "The Proxmox node to create the VM on"
}

variable "vm_id" {
  type        = number
  description = "The ID of the VM"
}

variable "template_vm_id" {
  type        = number
  description = "The VMID of the template to clone from (e.g. the Packer-built 9001)"
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "cpu_type" {
  type        = string
  default     = "host"
  description = "CPU type"
}

variable "memory_dedicated" {
  type        = number
  default     = 2048
  description = "Dedicated memory in MB"
}

variable "disk_size" {
  type        = number
  default     = 16
  description = "Root disk size in GB (grown from the template's disk at clone time)"
}

variable "disk_datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "Datastore for the VM disk and cloud-init drive"
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Network bridge to attach the VM to"
}

variable "ip_address" {
  type        = string
  default     = "dhcp"
  description = "IPv4 address for cloud-init (e.g. \"dhcp\" or \"192.168.1.50/24\")"
}

variable "tags" {
  type        = list(string)
  default     = ["terraform"]
  description = "Tags for the VM"
}

variable "started" {
  type        = bool
  default     = true
  description = "Whether the VM should be running"
}

variable "on_boot" {
  type        = bool
  default     = true
  description = "Start the VM automatically when the Proxmox host boots"
}

variable "snippet_datastore_id" {
  type        = string
  default     = "local"
  description = "Datastore holding the cloud-init snippet (must have the Snippets content type enabled)"
}

variable "cloud_init_user_data" {
  type        = string
  default     = null
  description = "Rendered cloud-init user-data. When set, it is uploaded as a snippet and wired into the VM; the ubuntu user and SSH keys must be defined inside it."
}

variable "cloud_init_file_name" {
  type        = string
  default     = null
  description = "File name for the cloud-init snippet. Defaults to cloud-init-<name>.yml."
}
