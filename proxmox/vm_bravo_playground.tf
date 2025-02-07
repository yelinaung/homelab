# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "proxmox_virtual_environment_vm" "bravo_ubuntu" {
  acpi                = true
  bios                = "seabios"
  boot_order          = null
  description         = null
  hook_script_file_id = null
  keyboard_layout     = null
  kvm_arguments       = null
  mac_addresses       = ["00:00:00:00:00:00", "0A:B1:37:E1:7C:26", "02:42:26:8B:7C:C0", "0E:17:1C:B7:B4:C4", "00:00:00:00:00:00"]
  machine             = null
  migrate             = null
  name                = "bravo-ubuntu-server-22.04"
  node_name           = "homelab2"
  on_boot             = null
  pool_id             = null
  protection          = false
  reboot              = null
  scsi_hardware       = "virtio-scsi-single"
  started             = true
  stop_on_destroy     = null
  tablet_device       = true
  tags                = ["linux", "ubuntu", "terraform"]
  template            = false
  vm_id               = 101
  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = null
  }
  cpu {
    affinity     = null
    architecture = null
    cores        = 2
    flags        = []
    hotplugged   = 0
    limit        = 0
    numa         = false
    sockets      = 1
    type         = "x86-64-v2-AES"
    units        = 1024
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local"
    discard           = "ignore"
    file_id           = null
    interface         = "ide2"
    iothread          = false
    path_in_datastore = "iso/ubuntu-22.04.3-live-server-amd64.iso"
    replicate         = true
    serial            = null
    size              = 1
    ssd               = false
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    file_id           = null
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-101-disk-0"
    replicate         = true
    serial            = null
    size              = 100
    ssd               = false
  }
  memory {
    dedicated = 4096
    floating  = 0
    shared    = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "0A:B1:37:E1:7C:26"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    trunks       = null
    vlan_id      = 0
  }
  operating_system {
    type = "l26"
  }
  vga {
    clipboard = null
    memory    = 16
  }
}
