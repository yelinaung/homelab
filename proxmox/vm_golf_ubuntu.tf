module "golf_ubuntu" {
  source = "./modules/vm_module"

  name                 = "golf-ubuntu-22.04"
  node_name            = "homelab1"
  vm_id                = 105
  memory_dedicated     = 1024
  disk_size            = 32
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-22.04.3-live-server-amd64.iso"
  cpu_cores            = 1
  mac_address          = "BC:24:11:35:C3:EA"
  tags                 = ["linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
