module "grafana_ubuntu" {
  source = "./modules/vm_module"

  name                 = "grafana"
  node_name            = "homelab2"
  vm_id                = 104
  memory_dedicated     = 4096
  disk_size            = 32
  disk_datastore_id    = "local-lvm"
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-24.04.1-live-server-amd64.iso" # Set proper path even though not used
  cpu_cores            = 2
  mac_address          = "BC:24:11:B0:B9:05"
  tags                 = ["24.04", "linux", "ubuntu", "terraform"]
  enable_iso_disk      = false
}
