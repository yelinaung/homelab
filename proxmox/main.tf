terraform {
  required_version = ">= 1.10.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.93.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.endpoint
  username = var.username
  password = var.password
  ssh {
    agent    = true
    username = "root"
  }
}
