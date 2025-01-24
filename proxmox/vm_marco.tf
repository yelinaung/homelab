data "local_file" "ubuntu_ssh_public_key" {
  filename = "./data/ubuntu.pub"
}

# TODO abstract these into a module
resource "proxmox_virtual_environment_vm" "marco_ubuntu_vm" {
  name        = "marco-ubuntu"
  node_name   = "homelab2"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  vm_id       = 116

  agent {
    enabled = true
  }

  initialization {
    user_account {
      username = "ubuntu"
      password = random_password.ubuntu_vm_password.result
      keys     = [trimspace(data.local_file.ubuntu_ssh_public_key.content)]
    }
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "homelab2-data2:iso/ubuntu-24.04.1-live-server-amd64.iso"
    interface    = "virtio0"
    size         = 30
  }

  cdrom {
    enabled = true
    file_id = "homelab2-data2:iso/ubuntu-24.04.1-live-server-amd64.iso"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X
  }
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}
