terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc2"
    }
  }
}

variable "proxmox_api_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "pve_user" {
  type = string
}
variable "pve_user_password" {
  type      = string
  sensitive = true
}
variable "pve_host" {
  type = string
}

variable "vm_name" {
  type = string
}
variable "vm_user_password" {
  type      = string
  sensitive = true
}
variable "adm_username" {
  type = string
}
variable "adm_pwd" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" {
  type = string
}
//
// 192.168.1.110/24
//

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  # (Optional) Skip TLS Verification
  pm_tls_insecure = true

}
