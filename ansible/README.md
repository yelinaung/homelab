## Testing

Syntax validation and linting
```shell
$ uv run --python 3.14 --with ansible-playbook ansible-playbook ./ansible/playbooks/install_vector.yaml --syntax-check
$ uv run --python 3.14 --with ansible-lint ansible-lint ansible/playbooks/install_vector.yaml -v
$ uv run --python 3.14 --with yamllint yamllint ansible/playbooks/install_vector.yaml
```

Dry-run with an actual target
```shell
$ ansible-playbook -i ansible/inventory/linux_hosts.yaml \
    ansible/playbooks/install_vector.yaml \
    --check \
    --diff \
    -e "vm_hosts=<test-vm-name>"
```
What it does:
- `--check` = Don't actually change anything (dry-run)
- `--diff` = Show what WOULD change
- Shows errors without breaking anything

Verification tasks

```yaml
- name: Verify Nginx is running
  ansible.builtin.systemd:
    name: nginx
    state: started
- name: Verify Nginx is accessible
  ansible.builtin.uri:
    url: http://localhost
    status_code: 200
```

Ansible [Molecule](https://docs.ansible.com/projects/molecule/)

This is like pytest for Ansible. It:
- Spins up test VMs (Docker, Vagrant, etc.)
- Runs the playbook
- Verifies the results
- Tears down the environment
