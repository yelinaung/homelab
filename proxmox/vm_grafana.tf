resource "proxmox_virtual_environment_vm" "grafana_ubuntu" {
  acpi                = true
  bios                = "seabios"
  boot_order          = null
  description         = null
  hook_script_file_id = null
  keyboard_layout     = null
  kvm_arguments       = null
  machine             = null
  migrate             = null
  name                = "grafana"
  node_name           = "homelab2"
  on_boot             = null
  pool_id             = null
  protection          = false
  reboot              = null
  scsi_hardware       = "virtio-scsi-single"
  started             = true
  stop_on_destroy     = null
  tablet_device       = true
  tags                = ["24.04", "linux", "ubuntu", "terraform"]
  template            = false
  timeout_clone       = null
  timeout_create      = null
  timeout_migrate     = null
  timeout_reboot      = null
  timeout_shutdown_vm = null
  timeout_start_vm    = null
  timeout_stop_vm     = null
  vm_id               = 104
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
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    file_id           = null
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-104-disk-0"
    replicate         = true
    serial            = null
    size              = 32
    ssd               = false
  }
  memory {
    dedicated      = 4096
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
    mac_address  = "BC:24:11:B0:B9:05"
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
    type      = null
  }
}
