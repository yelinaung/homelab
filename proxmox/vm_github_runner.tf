variable "github_runner_pat" {
  type        = string
  sensitive   = true
  description = "GitHub Personal Access Token with repo scope for the runner."
}

# Cloud-init user data uploaded as a snippet. The 'local' datastore on the
# node must have the "Snippets" content type enabled.
resource "proxmox_virtual_environment_file" "github_runner_cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab3"

  source_raw {
    file_name = "cloud-init-github-runner.yml"
    data = templatefile("${path.module}/templates/cloud-init-runner.yml.tftpl", {
      github_owner      = "yelinaung"
      github_repository = "homelab"
      github_pat        = var.github_runner_pat
      ssh_public_key    = trimspace(file("${path.module}/data/ubuntu.pub"))
    })
  }
}

resource "proxmox_virtual_environment_vm" "github_runner" {
  name      = "github-runner"
  node_name = "homelab3"
  vm_id     = 130
  tags      = ["linux", "ubuntu", "terraform", "runner"]

  # Clone from the ubuntu-24.04-packer template built by proxmox/packer/
  clone {
    vm_id = 9001
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # cicustom replaces the whole user config, so the ubuntu user and SSH key
    # live in the snippet template, not in a user_account block.
    user_data_file_id = proxmox_virtual_environment_file.github_runner_cloud_init.id
  }
}
