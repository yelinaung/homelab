# resource "proxmox_virtual_environment_container" "beszel_container" {
#   description = "Managed by Terraform"
#
#   node_name = "homelab2"
#   vm_id     = 1000
#
#   initialization {
#     hostname = "terraform-provider-proxmox-beszel-container"
#
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#
#     user_account {
#       keys = [
#         trimspace(tls_private_key.beszel_container_key.public_key_openssh)
#       ]
#       password = random_password.beszel_container_password.result
#     }
#   }
#
#   network_interface {
#     name = "veth0"
#   }
#
#   operating_system {
#     template_file_id = proxmox_virtual_environment_download_file.latest_beszel_22_jammy_lxc_img.id
#     # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
#     # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
#     type = "beszel"
#   }
#
#   mount_point {
#     # bind mount, *requires* root@pam authentication
#     volume = "/mnt/bindmounts/shared"
#     path   = "/mnt/shared"
#   }
#
#   mount_point {
#     # volume mount, a new volume will be created by PVE
#     volume = "local-lvm"
#     size   = "10G"
#     path   = "/mnt/volume"
#   }
#
#   startup {
#     order      = "3"
#     up_delay   = "60"
#     down_delay = "60"
#   }
# }
#
# resource "proxmox_virtual_environment_download_file" "latest_beszel_22_jammy_lxc_img" {
#   content_type = "vztmpl"
#   datastore_id = "local"
#   node_name    = "first-node"
#   url          = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
# }
#
# resource "random_password" "beszel_container_password" {
#   length           = 16
#   override_special = "_%@"
#   special          = true
# }
#
# resource "tls_private_key" "beszel_container_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }
#
# output "beszel_container_password" {
#   value     = random_password.beszel_container_password.result
#   sensitive = true
# }
#
# output "beszel_container_private_key" {
#   value     = tls_private_key.beszel_container_key.private_key_pem
#   sensitive = true
# }
#
# output "beszel_container_public_key" {
#   value = tls_private_key.beszel_container_key.public_key_openssh
# }
