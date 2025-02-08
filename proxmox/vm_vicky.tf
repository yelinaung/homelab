# __generated__ by Terraform from "homelab/113"
resource "proxmox_virtual_environment_vm" "vicky" {
  acpi          = true
  bios          = "seabios"
  name          = "vicky"
  node_name     = "homelab"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = ["24.04", "linux", "ubuntu", "db", "terraform"]
  template      = false
  vm_id         = 113
  agent {
    enabled = true
    timeout = "15m"
    trim    = false
  }
  cpu {
    cores      = 4
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 1
    type       = "x86-64-v2-AES"
    units      = 1024
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-113-disk-0"
    replicate         = true
    size              = 100
    ssd               = false
  }
  memory {
    dedicated      = 8192
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "BC:24:11:33:AF:46"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    type = "l26"
  }
}
