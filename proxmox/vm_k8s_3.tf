resource "proxmox_virtual_environment_vm" "k8s_vm3" {
  vm_id         = 110
  acpi          = true
  bios          = "seabios"
  name          = "k8s-vm3"
  node_name     = "homelab"
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
    path_in_datastore = "iso/ubuntu-20.04.6-live-server-amd64.iso"
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
    path_in_datastore = "vm-110-disk-0"
    replicate         = true
    serial            = null
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
    mac_address  = "BC:24:11:5A:B0:D0"
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
