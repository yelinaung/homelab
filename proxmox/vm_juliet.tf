module "juliet_ubuntu" {
  source = "./modules/vm_module"

  name                  = "juliet-ubuntu-arm"
  node_name             = "homelab"
  vm_id                 = 114
  memory_dedicated      = 8196
  cpu_cores             = 4
  disk_size             = 42
  tags                  = ["debian", "linux", "terraform"]
  vm_disk_datastore_id  = "homelab1-data"
  disk_datastore_id     = "homelab1-data"
  iso_path              = "" # No ISO needed as it's using existing disk
  enable_iso_disk       = false
  mac_address           = "BC:24:11:4F:08:80"
  cpu_type              = "qemu64"
  bios                  = "ovmf"
  enable_efi_disk       = true
  efi_disk_datastore_id = "local-lvm"
  efi_disk_file_format  = "raw"
  efi_disk_type         = "4m"
  efi_pre_enrolled_keys = false
  disk_file_format      = "qcow2"
  disk_path_prefix      = "114/"
  enable_serial_device  = true
  enable_vga            = true
}
