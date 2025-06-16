terraform {
  required_version = ">= 1.10.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}
