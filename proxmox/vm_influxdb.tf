module "influxdb" {
  source = "./modules/vm_module"

  name                 = "influxdb"
  node_name            = "homelab2"
  vm_id                = 115
  memory_dedicated     = 2048
  disk_size            = 32
  vm_disk_datastore_id = "homelab2-data2"
  iso_datastore_id     = "homelab2-data2"
  iso_path             = "iso/ubuntu-24.04.1-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:19:47:DE"
  tags                 = ["linux", "ubuntu", "db", "terraform"]
  iso_disk_size        = 2
  disk_file_format     = "qcow2"
  disk_path_prefix     = "115/"
}
