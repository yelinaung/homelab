resource "proxmox_virtual_environment_vm" "influxdb" {
  vm_id         = 115
  acpi          = true
  bios          = "seabios"
  name          = "influxdb"
  node_name     = "homelab2"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = ["linux", "ubuntu", "db", "terraform"]
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
    datastore_id      = "homelab2-data2"
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
    datastore_id      = "homelab2-data2"
    discard           = "ignore"
    file_format       = "qcow2"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "115/vm-115-disk-0.qcow2"
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
    mac_address  = "BC:24:11:19:47:DE"
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
