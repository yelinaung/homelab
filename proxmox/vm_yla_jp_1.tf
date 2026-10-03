module "yla_jp_1" {
  source = "./modules/vm_clone_module"

  name               = "yla-jp-1"
  node_name          = "homelab1"
  vm_id              = 132
  template_vm_id     = 9001
  template_node_name = "homelab3"
  cpu_cores          = 4
  memory_dedicated   = 16384
  disk_size          = 100
  tags               = ["24.04", "linux", "ubuntu", "terraform"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
    hostname       = "yla-jp-1"
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
