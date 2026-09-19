module "sportzx" {
  source = "./modules/vm_clone_module"

  name             = "sportzx"
  node_name        = "homelab3"
  vm_id            = 131
  template_vm_id   = 9001
  cpu_cores        = 2
  memory_dedicated = 2048
  disk_size        = 32
  tags             = ["24.04", "linux", "ubuntu", "terraform"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
    hostname       = "sportzx"
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
