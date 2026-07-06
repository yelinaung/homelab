packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "ubuntu-cloud" {
  // Proxmox connection
  proxmox_url              = var.pve_api_url
  username                 = var.pve_username
  token                    = var.pve_token
  node                     = var.pve_node
  insecure_skip_tls_verify = true

  // Clone settings
  clone_vm             = "ubuntu-24.04-template" // Name of your cloud image template
  vm_id                = 9001                    // Stable ID so Terraform can clone { vm_id = 9001 }
  template_name        = "ubuntu-24.04-packer"
  template_description = "Ubuntu 24.04 template built with Packer from cloud image"

  // VM settings — the plugin does NOT inherit these from the cloned template;
  // its defaults (scsi_controller=lsi, os=other) leave the cloud image unbootable.
  cores           = 2
  memory          = 2048
  scsi_controller = "virtio-scsi-pci"
  os              = "l26"
  cpu_type        = "host"

  // Cloud-init settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  // SSH settings
  ssh_username = "ubuntu"
  ssh_timeout  = "15m" # first boot runs apt update + installs qemu-guest-agent before an IP is reported
}

build {
  source "proxmox-clone.ubuntu-cloud" {
    ssh_private_key_file = "~/.ssh/id_rsa"
  }

  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id"
    ]
  }
}
