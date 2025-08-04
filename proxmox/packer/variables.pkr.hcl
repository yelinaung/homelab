// ISO Variables //
variable "iso_download_pve" {
  description = "Download the ISO directly on the Proxmox node."
  type        = bool
  default     = true
}

variable "iso_storage_pool" {
  type    = string
  default = "local"
}

variable "apt_proxy_http" {
  description = <<EOT
  APT proxy URL for Ubuntu, format: 'http://[[user][:pass]@]host[:port]/'. Default 'null' skips setting proxy.
  EOT
  type        = string
  default     = ""
}

variable "apt_proxy_https" {
  description = <<EOT
  APT proxy URL for Ubuntu, format: 'https://[[user][:pass]@]host[:port]/'. Default 'null' skips setting proxy.
  EOT
  type        = string
  default     = ""
}

variable "iso_url" {
  type = map(string)
  default = {
    "ubuntu22" = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
    "ubuntu24" = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
  }
}

variable "iso_checksum" {
  type = map(string)
  default = {
    "ubuntu22" = "file:https://releases.ubuntu.com/22.04/SHA256SUMS"
    "ubuntu24" = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
  }
}

variable "unmount_iso" {
  type    = bool
  default = true
}

variable "os" {
  description = "OS Type, defaults to Linux 6.x-2.6 Kernel"
  type        = string
  default     = "l26"
}

variable "vm_id" {
  type = map(number)
  default = {
    "ubuntu22" = 0
    "ubuntu24" = 0
  }
}

// Boot Commands //
variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "boot_cmd_ubuntu22" {
  description = "Boot command for Ubuntu 22 & 24"
  type        = list(string)
  default = [
    "c",
    "linux /casper/vmlinuz --- autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot<enter>"
  ]
}

// SSH Variables //
variable "ssh_username" {
  description = "SSH Username During Packer Build"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH Password During Packer Build"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "ssh_timeout" {
  type    = string
  default = "20m"
}

variable "ssh_keypair_name" {
  default = "packer_id_ed25519"
  type    = string
}

variable "ssh_private_key_file" {
  description = "Private SSH Key for VM"
  default     = "~/.ssh/packer_id_ed25519"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_file" {
  description = "Public SSH Key for VM"
  default     = "~/.ssh/packer_id_ed25519.pub"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.ssh_public_key_file)) == false
    error_message = "ERROR Private SSH Key."
  }
}

variable "ssh_clear_authorized_keys" {
  type    = bool
  default = true
}

// PVE Variables //
// Sensitive Variables to Pass as CLI Args or Env Vars
variable "pve_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "pve_username" {
  description = "Username when authenticating to Proxmox, including the realm."
  type        = string
  sensitive   = true
}

variable "pve_api_url" {
  description = "Proxmox API Endpoint, e.g. 'https://pve.example.com/api2/json'"
  type        = string
  sensitive   = true
  # validation {
  #   condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
  #   error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  # }
}

// Non-Sensitive Variables
variable "pve_node" {
  type    = string
  default = "pve"
}

variable "skip_tls_check" {
  type    = bool
  default = true
}

// System Variables //
variable "machine" {
  type    = string
  default = "q35"
}

variable "bios" {
  type    = string
  default = "seabios"
}

variable "qemu_agent" {
  type    = bool
  default = true
}

variable "scsi_controller" {
  type    = string
  default = "virtio-scsi-pci"
}

// Cloud-init Variables //
variable "cloud_init" {
  description = "Attach cloud-init drive."
  type        = bool
  default     = true
}

variable "cloud_init_storage_pool" {
  description = "Proxmox storage pool to use for cloud-init drive, e.g. 'local-lvm' (default)."
  type        = string
  default     = "local-lvm"
}

// CPU & Memory Variables //
variable "sockets" {
  type    = number
  default = 1
}

variable "vcpu" {
  type    = number
  default = 2
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "memory" {
  type    = number
  default = 2048
}

// Disk Variables //
variable "disk_cache_mode" {
  type    = string
  default = "writeback"
}

variable "disk_discard" {
  type    = bool
  default = false
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_io_thread" {
  type    = bool
  default = false
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_ssd" {
  type    = bool
  default = false
}

variable "disk_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "disk_type" {
  type    = string
  default = "scsi"
}

// Network Variables //
variable "net_bridge" {
  type    = string
  default = "vmbr0"
}

variable "net_model" {
  type    = string
  default = "virtio"
}

variable "net_vlan_tag" {
  type    = string
  default = "1"
}

variable "net_firewall" {
  type    = bool
  default = false
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to be added to the authorized_keys file."
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBcvCv2ynfYVr2yKDk0CVdK5ZHg7xYsi0MIxN3fL6Hfi packer"
}
