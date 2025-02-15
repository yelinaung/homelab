module "k8s_vm1" {
  source = "./modules/vm_module"

  name                 = "k8s-vm1"
  node_name            = "homelab"
  vm_id                = 108
  memory_dedicated     = 8192
  disk_size            = 50
  disk_datastore_id    = "local"
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-20.04.6-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:AD:D7:BF"
  tags                 = ["20.04", "k8s", "linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
