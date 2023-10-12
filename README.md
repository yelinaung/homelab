### Anisble Configs and Playbook for the Homelab


- Installing zsh on Proxmox servers
```bash
$ ansible-playbook ./playbooks/install_zsh.yaml --ask-pass --ask-become-pass -i ./inventory/hosts
```

- Updating apt on Ubuntu VMs
```bash
$ ansible-playbook ./playbooks/apt_ubuntu_vms.yaml --ask-become-pass -i ./inventory/hosts
```
