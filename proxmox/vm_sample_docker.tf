# Sample VM cloned from the Packer golden template (9001): cloud-init installs
# Docker and runs a demo container reachable on port 80.
module "sample_docker" {
  source = "./modules/vm_clone_module"

  count            = 0
  name             = "sample-docker"
  node_name        = "homelab3"
  vm_id            = 130
  template_vm_id   = 9001
  cpu_cores        = 2
  memory_dedicated = 2048
  disk_size        = 16
  tags             = ["linux", "ubuntu", "terraform", "docker"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-sample-docker.yml.tftpl", {
    container_name  = "hello-nginx"
    container_image = "nginx:alpine"
    ssh_public_key  = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
