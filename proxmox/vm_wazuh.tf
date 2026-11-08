# Wazuh single-node server (manager + indexer + dashboard). The indexer is
# OpenSearch, so it gets vicky-class resources. Ansible installs Wazuh later.
module "wazuh" {
  source = "./modules/vm_clone_module"

  name               = "wazuh"
  node_name          = "homelab1"
  vm_id              = 134
  template_vm_id     = 9003
  template_node_name = "homelab3"
  cpu_cores          = 4
  memory_dedicated   = 12288
  disk_size          = 100
  tags               = ["26.04", "linux", "ubuntu", "terraform", "security"]

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-base.yml.tftpl", {
    hostname       = "wazuh"
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
  })
}
