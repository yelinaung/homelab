module "k8s_vm3" {
  source = "./modules/vm_module"

  name                 = "k8s-vm3"
  node_name            = "homelab1"
  vm_id                = 110
  memory_dedicated     = 8192
  disk_size            = 50
  vm_disk_datastore_id = "local-lvm"
  iso_path             = "iso/ubuntu-20.04.6-live-server-amd64.iso"
  cpu_cores            = 2
  mac_address          = "BC:24:11:5A:B0:D0"
  tags                 = ["20.04", "k8s", "linux", "ubuntu", "terraform"]
  iso_disk_size        = 1
}
