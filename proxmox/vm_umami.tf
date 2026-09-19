module "umami" {
  source = "./modules/vm_module"

  name                 = "umami"
  node_name            = "homelab1"
  vm_id                = 112
  memory_dedicated     = 2048
  disk_size            = 32
  vm_disk_datastore_id = "homelab1-data"
  cpu_cores            = 2
  mac_address          = "BC:24:11:5A:AC:60"
  tags                 = ["24.04", "linux", "ubuntu", "terraform"]

  enable_iso_disk  = true
  iso_disk_size    = 2
  iso_datastore_id = "homelab1-data"
  disk_file_format = "qcow2"
  disk_path_prefix = "112/"
}
