# Reusable VM built by cloning a template (e.g. the Packer-built 9001) and
# provisioning it with cloud-init. Unlike ../vm_module (which adopts
# hand-created VMs and freezes them via ignore_changes), Terraform fully
# manages the cloned VM here.

locals {
  has_cloud_init = var.cloud_init_user_data != null
  snippet_name   = coalesce(var.cloud_init_file_name, "cloud-init-${var.name}.yml")
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  count = local.has_cloud_init ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippet_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = local.snippet_name
    data      = var.cloud_init_user_data
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id
  tags      = var.tags
  started   = var.started
  on_boot   = var.on_boot

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_dedicated
  }

  disk {
    datastore_id = var.disk_datastore_id
    interface    = "scsi0"
    size         = var.disk_size
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  initialization {
    datastore_id = var.disk_datastore_id

    ip_config {
      ipv4 {
        address = var.ip_address
      }
    }

    # cicustom replaces the whole user config, so the ubuntu user and SSH keys
    # must live inside cloud_init_user_data, not a user_account block.
    user_data_file_id = local.has_cloud_init ? proxmox_virtual_environment_file.cloud_init[0].id : null
  }
}
