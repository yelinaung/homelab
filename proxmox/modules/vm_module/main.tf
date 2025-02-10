resource "proxmox_virtual_environment_vm" "vm" {
  acpi          = true
  bios          = "seabios"
  name          = var.name
  node_name     = var.node_name
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = var.tags
  template      = false
  vm_id         = var.vm_id

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = null
  }

  cpu {
    cores      = var.cpu_cores
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
    datastore_id      = var.disk_datastore_id
    discard           = "ignore"
    file_id           = null
    interface         = "ide2"
    iothread          = false
    path_in_datastore = var.iso_path
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
    path_in_datastore = "vm-${var.vm_id}-disk-0"
    replicate         = true
    serial            = null
    size              = var.disk_size
    ssd               = false
  }

  memory {
    dedicated = var.memory_dedicated
    floating  = 0
    shared    = 0
  }

  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = var.mac_address
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
}
