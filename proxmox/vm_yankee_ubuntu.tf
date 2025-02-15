module "yankee_ubuntu" {
  source = "./modules/vm_module"

  name             = "yankee-ubuntu-24-04"
  node_name        = "homelab2"
  vm_id            = 111
  memory_dedicated = 2048
  cpu_cores        = 2
  mac_address      = "BC:24:11:EA:FB:A3"
  tags             = ["24.04", "linux", "ubuntu", "terraform"]

  # normal disk
  disk_size            = 32
  vm_disk_datastore_id = "local-lvm"

  # iso disk
  iso_disk_size   = 2
  iso_path        = "iso/ubuntu-24.04-live-server-amd64.iso"
  enable_iso_disk = true
}
