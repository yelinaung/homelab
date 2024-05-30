resource "null_resource" "cloud_init_user_data_file" {
  connection {
    user        = "root"
    private_key = var.root_private_key
    host        = var.pve_host
    port        = 22
  }

  provisioner "file" {
    content = templatefile(
      "../files/cloud-init/cloud-init.cloud_config_user.tftpl",
      {
        hostname            = var.vm_name,
        user                = var.adm_username,
        password            = var.adm_pwd,
        ssh_authorized_keys = var.ssh_authorized_keys,
      }
    )
    destination = "/var/lib/vz/snippets/user_data_vm-${var.vm_name}.yml"
  }

  triggers = {
    hostname            = var.vm_name,
    user                = var.adm_username,
    ssh_authorized_keys = var.ssh_authorized_keys,
    password            = var.adm_pwd,
  }
}

resource "null_resource" "cloud_init_network_data_file" {
  connection {
    user        = "root"
    private_key = var.root_private_key
    host        = var.pve_host
    port        = 22
  }

  provisioner "file" {
    content = templatefile(
      "../files/cloud-init/cloud-init.cloud_config_network.tftpl",
      {
        ip_dns = var.ip_dns,
      }
    )
    destination = "/var/lib/vz/snippets/network_data_vm-${var.vm_name}.yml"
  }

  triggers = {
    ip_dns = var.ip_dns,
  }
}

resource "proxmox_vm_qemu" "k8s_vm1" {
  name        = var.vm_name
  desc        = "k8s-vm1 ubuntu 22.04"
  vmid        = "400"
  clone       = "ubuntu-server-jammy-22-04"
  full_clone  = true
  target_node = "homelab"
  bootdisk    = "scsi0"
  agent       = 1

  onboot = true

  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 4096

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "30G"
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = false
  }

  os_type           = "cloud-init"
  os_network_config = <<EOF
auto eth0
iface eth0 inet dhcp
EOF

  ciuser     = "ubuntu"
  cipassword = var.vm_user_password
  sshkeys    = var.ssh_public_key

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.pve_user
      password = var.pve_user_password
      host     = var.pve_host
    }

    inline = [
      "ip a"
    ]
  }
}
