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

variable "memory_floating" {
  default     = 0
  type        = number
  description = "The amount of floating memory for the VM (in MB)"
}

variable "disk_size" {
  default     = 1
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

variable "enable_iso_disk" {
  type        = bool
  default     = true
  description = "Whether to enable the ISO disk block (default: true)"
}

variable "cpu_type" {
  type        = string
  default     = "x86-64-v2-AES"
  description = "The CPU type for the VM (default: x86-64-v2-AES)"
}

variable "enable_efi_disk" {
  type        = bool
  default     = false
  description = "Whether to enable EFI disk block (default: false)"
}

variable "efi_disk_type" {
  type        = string
  default     = "4m"
  description = "The EFI disk type (default: 4m)"
}

variable "efi_disk_datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "The datastore ID for the EFI disk (default: local-lvm)"
}

variable "efi_disk_file_format" {
  type        = string
  default     = "raw"
  description = "The file format for the EFI disk (default: raw)"
}

variable "efi_pre_enrolled_keys" {
  type        = bool
  default     = false
  description = "Whether to pre-enroll keys for the EFI disk (default: false)"
}

variable "bios" {
  type        = string
  default     = "seabios"
  description = "The BIOS type for the VM (default: seabios)"
}

variable "enable_initialization" {
  type        = bool
  default     = false
  description = "Whether to enable initialization block (default: false)"
}

variable "initialization_username" {
  type        = string
  default     = ""
  description = "The username for the initialization user account"
}

variable "initialization_password" {
  type        = string
  default     = ""
  description = "The password for the initialization user account"
  sensitive   = true
}

variable "initialization_ssh_keys" {
  type        = list(string)
  default     = []
  description = "List of SSH public keys for the initialization user account"
}

variable "disk_file_format" {
  type        = string
  default     = "raw"
  description = "The file format for the main disk (default: raw)"
}

variable "disk_path_prefix" {
  type        = string
  default     = ""
  description = "Optional prefix for the disk path (e.g., '115/' for 'vm-115-disk-0.qcow2')"
}
