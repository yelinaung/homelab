# Semaphore UI: schedules and runs the Ansible playbooks in this repository.
# Kept on its own VM so maintenance runs never update their own controller
# mid-run. Ansible (install_semaphore.yaml) installs Semaphore later.
module "semaphore" {
  source = "./modules/vm_clone_module"

  name             = "semaphore"
  node_name        = "homelab3"
  vm_id            = 135
  template_vm_id   = 9003
  cpu_cores        = 2
  memory_dedicated = 4096
  disk_size        = 32
  tags             = ["26.04", "linux", "ubuntu", "terraform"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
    hostname       = "semaphore"
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
