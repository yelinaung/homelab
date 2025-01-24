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
# import {
#   to = proxmox_virtual_environment_vm.alpha_ubuntu
#   id = "homelab/100"
# }

# resource "proxmox_virtual_environment_vm" "alpha_ubuntu" {
#   name      = "alpha-ubuntu-24-04"
#   node_name = "homelab"
#   vm_id     = 100
#   agent {
#     enabled = true
#   }
#   tags = [
#     "24.04",
#     "linux",
#     "ubuntu",
#   ]
# }
