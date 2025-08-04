packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "image" {
  // PVE login
  proxmox_url              = var.pve_api_url
  username                 = var.pve_username
  token                    = var.pve_token
  node                     = var.pve_node
  insecure_skip_tls_verify = var.skip_tls_check

  // SSH
  ssh_username = "root"
  ssh_password = "" # TODO some password here
  ssh_timeout  = "20m"

  // ISO
  iso_file             = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
  iso_storage_pool     = var.iso_storage_pool
  unmount_iso          = var.unmount_iso
  os                   = var.os
  template_description = "Packer generated template image on ${timestamp()}"

  // System
  machine    = var.machine
  bios       = var.bios
  qemu_agent = false

  // Disks
  scsi_controller = var.scsi_controller
  disks {
    type         = var.disk_type
    storage_pool = var.disk_storage_pool
    disk_size    = var.disk_size
    cache_mode   = var.disk_cache_mode
    format       = var.disk_format
    io_thread    = var.disk_io_thread
    discard      = var.disk_discard
    ssd          = var.disk_ssd
  }

  // Cloud-init
  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_storage_pool

  // CPU & Memory
  sockets  = var.sockets
  cores    = var.vcpu
  cpu_type = var.cpu_type
  memory   = var.memory

  // Network
  network_adapters {
    bridge   = var.net_bridge
    model    = var.net_model
    vlan_tag = var.net_vlan_tag
    firewall = var.net_firewall
  }
}

build {
  source "proxmox-iso.image" {
    name         = "ubuntu24"
    boot_command = var.boot_cmd_ubuntu22 # same boot command for ubuntu 22.x and 24.x
    boot_wait    = var.boot_wait
    http_bind_address = "0.0.0.0"
    http_port_min = 8300
    http_port_max = 8400
    http_content = {
      "/meta-data" = file("configs/meta-data")
      "/user-data" = templatefile("configs/user-data",
        {
          var            = var,
          ssh_public_key = chomp(file(var.ssh_public_key_file))
      })
    }
    template_name = "ubuntu24"
    vm_id         = var.vm_id["ubuntu24"]
  }

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      // clean image identifiers
      "cloud-init clean --machine-id --seed",
      "rm /etc/hostname /etc/ssh/ssh_host_* /var/lib/systemd/random-seed",
      "truncate -s 0 /root/.ssh/authorized_keys",
      "sed -i 's/^#PasswordAuthentication\\ yes/PasswordAuthentication\\ no/' /etc/ssh/sshd_config",
      "sed -i 's/^#PermitRootLogin\\ prohibit-password/PermitRootLogin\\ no/' /etc/ssh/sshd_config"
    ]
  }
}
