module "yankee_ubuntu" {
  source = "./modules/vm_module"

  name                 = "yankee-ubuntu-24-04"
  node_name            = "homelab2"
  vm_id                = 111
  memory_dedicated     = 2048
  disk_size            = 32
  disk_datastore_id    = "local"
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-24.04-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:EA:FB:A3"
  tags                 = ["24.04", "linux", "ubuntu", "terraform"]
  iso_disk_size        = 2
}
