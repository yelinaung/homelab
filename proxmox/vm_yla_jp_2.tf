module "yla_jp_2" {
  source = "./modules/vm_clone_module"

  name               = "yla-jp-2"
  node_name          = "homelab2"
  vm_id              = 133
  template_vm_id     = 9001
  template_node_name = "homelab3"
  cpu_cores          = 4
  memory_dedicated   = 8192
  disk_size          = 100
  tags               = ["24.04", "linux", "ubuntu", "terraform"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
    hostname       = "yla-jp-2"
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
