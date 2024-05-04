### Anisble Configs and Playbook for the Homelab

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/yelinaung/ansible-configs/master.svg)](https://results.pre-commit.ci/latest/github/yelinaung/ansible-configs/master) [![lint](https://github.com/yelinaung/ansible-configs/actions/workflows/lint.yaml/badge.svg)](https://github.com/yelinaung/ansible-configs/actions/workflows/lint.yaml)

- [Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)

#### Running the Playbooks

- Updating packages with `apt` on the VMs on top of Proxmox
```bash
$ ansible-playbook ./playbooks/apt_ubuntu_vms.yaml -i ./inventory/hosts --extra-vars "hosts=vms_on_proxmox"
```

#### Configuring the Proxmox VMs

- https://forum.proxmox.com/threads/provision-vm-from-template-using-ansible.130596/#post-574285

### Role Used

- Jeff Geerling's [node exporter role](https://github.com/geerlingguy/ansible-role-node_exporter)
    - Make sure to install first by
    ```bash
    $ ansible-galaxy install geerlingguy.node_exporter
    ```

#### Documenetation

- Proxmox [apt](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html) module
