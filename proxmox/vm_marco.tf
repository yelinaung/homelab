data "local_file" "ubuntu_ssh_public_key" {
  filename = "./data/ubuntu.pub"
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

module "marco_ubuntu" {
  source = "./modules/vm_module"

  name                 = "marco-ubuntu"
  node_name            = "homelab2"
  vm_id                = 116
  memory_dedicated     = 2048
  memory_floating      = 2048
  cpu_cores            = 2
  disk_size            = 30
  tags                 = ["terraform", "ubuntu"]
  vm_disk_datastore_id = "local-lvm"
  iso_datastore_id     = "local-lvm"
  iso_path             = "iso/ubuntu-24.04.1-live-server-amd64.iso"

  # Initialization configuration
  enable_initialization   = true
  initialization_username = "ubuntu"
  initialization_password = random_password.ubuntu_vm_password.result
  initialization_ssh_keys = [trimspace(data.local_file.ubuntu_ssh_public_key.content)]
}
