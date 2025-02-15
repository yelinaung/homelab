module "umami" {
  source = "./modules/vm_module"

  name                 = "umami"
  node_name            = "homelab"
  vm_id                = 112
  memory_dedicated     = 2048
  disk_size            = 32
  disk_datastore_id    = "homelab1-data"
  vm_disk_datastore_id = "homelab1-data"
  iso_path             = "iso/ubuntu-24.04.1-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:5A:AC:60"
  tags                 = ["24.04", "linux", "ubuntu", "terraform"]
  iso_disk_size        = 2
}
