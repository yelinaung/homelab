### Anisble Configs and Playbook for the Homelab

- [Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)

#### Running the Playbooks

- Installing zsh on Proxmox servers
```bash
$ ansible-playbook ./playbooks/install_zsh.yaml  -i ./inventory/hosts
```

- Updating apt on Ubuntu VMs
```bash
$ ansible-playbook ./playbooks/apt_ubuntu_vms.yaml  -i ./inventory/hosts
```

#### Configuring the Proxmox VMs

- https://forum.proxmox.com/threads/provision-vm-from-template-using-ansible.130596/#post-574285
