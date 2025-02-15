module "bravo_ubuntu" {
  source = "./modules/vm_module"

  name                 = "bravo-ubuntu-server-22.04"
  node_name            = "homelab2"
  vm_id                = 101
  memory_dedicated     = 4096
  disk_size            = 100
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-22.04.3-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "0A:B1:37:E1:7C:26"
  tags                 = ["linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
