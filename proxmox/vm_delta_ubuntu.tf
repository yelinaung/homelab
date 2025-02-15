module "delta_ubuntu" {
  source = "./modules/vm_module"

  name                 = "delta-ubuntu-server-22.04"
  node_name            = "homelab"
  vm_id                = 103
  memory_dedicated     = 8192
  disk_size            = 40
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-22.04.3-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:63:3E:62"
  tags                 = ["linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
