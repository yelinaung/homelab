resource "proxmox_virtual_environment_vm" "umami" {
  vm_id         = 112
  acpi          = true
  bios          = "seabios"
  name          = "umami"
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
  }
  cpu {
    cores      = 2
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
    datastore_id      = "homelab1-data"
    discard           = "ignore"
    interface         = "ide2"
    iothread          = false
    path_in_datastore = "iso/ubuntu-24.04.1-live-server-amd64.iso"
    replicate         = true
    size              = 2
    ssd               = false
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "homelab1-data"
    discard           = "ignore"
    file_format       = "qcow2"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "112/vm-112-disk-0.qcow2"
    replicate         = true
    size              = 32
    ssd               = false
  }
  memory {
    dedicated      = 2048
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "BC:24:11:5A:AC:60"
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
