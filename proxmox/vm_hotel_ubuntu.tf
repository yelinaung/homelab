module "hotel_ubuntu" {
  source = "./modules/vm_module"

  name                 = "hotel-ubuntu-22.04-kr"
  node_name            = "homelab"
  vm_id                = 106
  memory_dedicated     = 1024
  disk_size            = 40
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-22.04.3-live-server-amd64.iso"
  cpu_cores            = 1
  mac_address          = "BC:24:11:E2:EA:B2"
  tags                 = ["linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
