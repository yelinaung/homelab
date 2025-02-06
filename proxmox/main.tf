terraform {
  required_version = ">= 1.10.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
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

import {
  to = proxmox_virtual_environment_vm.alpha_ubuntu
  id = "homelab/100"
}
