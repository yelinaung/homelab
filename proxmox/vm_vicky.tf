module "vicky" {
  source = "./modules/vm_module"

  name                 = "vicky"
  node_name            = "homelab1"
  vm_id                = 113
  memory_dedicated     = 8192
  disk_size            = 100
  vm_disk_datastore_id = "local-lvm"
  iso_path             = ""
  cpu_cores            = 4
  mac_address          = "BC:24:11:33:AF:46"
  tags                 = ["24.04", "linux", "ubuntu", "db", "terraform"]
  iso_disk_size        = 0
  enable_iso_disk      = false
}
