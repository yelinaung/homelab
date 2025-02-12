module "alpha_ubuntu" {
  source = "./modules/vm_module"

  name                   = "alpha-ubuntu-24-04"
  node_name              = "homelab"
  vm_id                  = 100
  memory_dedicated       = 4096
  disk_size              = 32
  disk_datastore_id      = "homelab1-data"
  vm_disk_datastore_id   = "local-lvm"
  iso_path               = "iso/ubuntu-24.04.1-live-server-amd64.iso"
  cpu_cores              = 2
  tags                   = ["24.04", "linux", "terraform", "ubuntu"]
}
