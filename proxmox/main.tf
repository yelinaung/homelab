terraform {
  required_version = ">= 1.10.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.101.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
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
