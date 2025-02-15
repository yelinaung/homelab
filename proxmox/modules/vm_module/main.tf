resource "proxmox_virtual_environment_vm" "vm" {
  acpi          = true
  bios          = var.bios
  name          = var.name
  node_name     = var.node_name
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = var.has_started
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
    cores        = var.cpu_cores
    architecture = var.cpu_architecture
    flags        = []
    hotplugged   = 0
    limit        = 0
    sockets      = 1
    type         = var.cpu_type
    units        = 1024
  }

  dynamic "disk" {
    for_each = var.enable_iso_disk ? [1] : []
    content {

      aio               = "io_uring"
      backup            = true
      cache             = "none"
      datastore_id      = var.iso_datastore_id
      discard           = "ignore"
      file_id           = null
      interface         = "ide2"
      iothread          = false
      path_in_datastore = var.iso_path
      replicate         = true
      serial            = null
      size              = var.iso_disk_size
      ssd               = false
    }
  }

  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = var.vm_disk_datastore_id
    discard           = "ignore"
    file_format       = var.disk_file_format
    file_id           = null
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "${var.disk_path_prefix}vm-${var.vm_id}-disk-0${var.disk_file_format == "qcow2" ? ".qcow2" : ""}"
    replicate         = true
    serial            = null
    size              = var.disk_size
    ssd               = false
  }

  memory {
    dedicated = var.memory_dedicated
    floating  = var.memory_floating
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

  dynamic "initialization" {
    for_each = var.enable_initialization ? [1] : []
    content {
      dynamic "user_account" {
        for_each = var.initialization_username != "" ? [1] : []
        content {
          username = var.initialization_username
          password = var.initialization_password
          keys     = var.initialization_ssh_keys
        }
      }
    }
  }

  dynamic "efi_disk" {
    for_each = var.enable_efi_disk ? [1] : []
    content {
      datastore_id      = var.efi_disk_datastore_id
      file_format       = var.efi_disk_file_format
      type              = var.efi_disk_type
      pre_enrolled_keys = var.efi_pre_enrolled_keys
    }
  }

  dynamic "serial_device" {
    for_each = var.enable_serial_device ? [1] : []
    content {
      device = "socket"
    }

  }

  dynamic "vga" {
    for_each = var.enable_vga ? [1] : []
    content {
      memory = 16
      type   = "serial0"
    }

  }
}
