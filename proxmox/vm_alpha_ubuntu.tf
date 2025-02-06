# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "proxmox_virtual_environment_vm" "alpha_ubuntu" {
  vm_id         = 100
  acpi          = true
  bios          = "seabios"
  mac_addresses = ["00:00:00:00:00:00", "BC:24:11:17:67:9B", "00:00:00:00:00:00"]
  name          = "alpha-ubuntu-24-04"
  node_name     = "homelab"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = ["24.04", "linux", "ubuntu", "terraform"]
  template      = false

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = null
  }

  cpu {
    cores      = 2
    flags      = []
    hotplugged = 0
    limit      = 0
    sockets    = 1
    type       = "x86-64-v2-AES"
    units      = 1024
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "homelab1-data"
    discard           = "ignore"
    file_id           = null
    interface         = "ide2"
    iothread          = false
    path_in_datastore = "iso/ubuntu-24.04.1-live-server-amd64.iso"
    replicate         = true
    serial            = null
    size              = 2
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
    path_in_datastore = "vm-100-disk-0"
    replicate         = true
    serial            = null
    size              = 32
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
    mac_address  = "BC:24:11:17:67:9B"
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
