# Base Ubuntu 26.04 cloud-image template (VMID 9002).
# Packer (proxmox/packer/) clones this and bakes qemu-guest-agent into
# the ubuntu-26.04-packer template (VMID 9003) that VMs clone from.

resource "proxmox_download_file" "ubuntu_2604_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "homelab3"
  file_name    = "resolute-server-cloudimg-amd64.img"
  url          = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
  # resolute/current/ is rebuilt upstream; don't re-download (and so replace
  # template 9000) on every size change. Refresh the image deliberately.
  overwrite = false
  # Take over the file if it already exists on the node (e.g. manual wget).
  overwrite_unmanaged = true
}

# First-boot cloud-init for clones of this template: creates the ubuntu user
# and installs qemu-guest-agent, which Packer/Terraform rely on for IP
# discovery. Cloud images don't ship the agent.
resource "proxmox_virtual_environment_file" "ubuntu_2604_template_cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab3"

  source_raw {
    file_name = "cloud-init-ubuntu-2604-template.yml"
    data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
      hostname       = "ubuntu-26-04-template"
      ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
    })
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_2604_template" {
  name      = "ubuntu-26.04-template"
  node_name = "homelab3"
  vm_id     = 9002
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
    file_id      = proxmox_download_file.ubuntu_2604_cloud_image.id
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

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_2604_template_cloud_init.id
  }
}
