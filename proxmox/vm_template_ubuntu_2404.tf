# Base Ubuntu 24.04 cloud-image template (VMID 9000).
# Packer (proxmox/packer/) clones this and bakes qemu-guest-agent into
# the ubuntu-24.04-packer template (VMID 9001) that VMs clone from.

resource "proxmox_download_file" "ubuntu_2404_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "homelab3"
  file_name    = "noble-server-cloudimg-amd64.img"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  overwrite    = true
  # Take over the file if it already exists on the node (e.g. manual wget).
  overwrite_unmanaged = true
}

# First-boot cloud-init for clones of this template: creates the ubuntu user
# and installs qemu-guest-agent, which Packer/Terraform rely on for IP
# discovery. Cloud images don't ship the agent.
resource "proxmox_virtual_environment_file" "ubuntu_2404_template_cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab3"

  source_raw {
    file_name = "cloud-init-ubuntu-2404-template.yml"
    data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
      ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
    })
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_2404_template" {
  name      = "ubuntu-24.04-template"
  node_name = "homelab3"
  vm_id     = 9000
  tags      = ["template", "ubuntu", "terraform"]

  template = true
  started  = false

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_download_file.ubuntu_2404_cloud_image.id
    interface    = "scsi0"
    size         = 8
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  vga {
    type = "serial0"
  }

  # The Packer build clones this template and logs in as 'ubuntu' with
  # ~/.ssh/id_rsa, so the key in the snippet must be its public half.
  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_2404_template_cloud_init.id
  }
}
