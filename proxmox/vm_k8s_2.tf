resource "proxmox_virtual_environment_vm" "k8s_vm2" {
  vm_id         = 109
  acpi          = true
  bios          = "seabios"
  name          = "k8s-vm2"
  node_name     = "homelab2"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = ["20.04", "k8s", "linux", "ubuntu", "terraform"]
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
    datastore_id      = "local"
    discard           = "ignore"
    interface         = "ide2"
    iothread          = false
    path_in_datastore = "iso/ubuntu-20.04.6-live-server-amd64.iso"
    replicate         = true
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
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-109-disk-0"
    replicate         = true
    size              = 50
    ssd               = false
  }
  memory {
    dedicated      = 8192
    floating       = 0
    hugepages      = null
    keep_hugepages = false
    shared         = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "BC:24:11:25:DC:9C"
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
