resource "proxmox_virtual_environment_vm" "juliet_ubuntu_arm" {
  vm_id         = 114
  acpi          = true
  bios          = "ovmf"
  name          = "juliet-ubuntu-arm"
  node_name     = "homelab"
  protection    = false
  scsi_hardware = "virtio-scsi-pci"
  started       = true
  tablet_device = true
  tags          = ["linux", "debian", "terraform"]
  template      = false
  agent {
    type    = "virtio"
    enabled = true
    timeout = "15m"
    trim    = false
  }
  cpu {
    architecture = "aarch64"
    cores        = 4
    flags        = []
    hotplugged   = 0
    limit        = 0
    numa         = false
    sockets      = 1
    type         = "qemu64"
    units        = 1024
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
    path_in_datastore = "114/vm-114-disk-0.qcow2"
    replicate         = true
    size              = 42
    ssd               = false
  }
  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    pre_enrolled_keys = false
    type              = "4m"
  }
  memory {
    dedicated      = 8196
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "BC:24:11:4F:08:80"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    type = "l26"
  }
  serial_device {
    device = "socket"
  }
  vga {
    memory = 16
    type   = "serial0"
  }
}
