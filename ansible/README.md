## Testing

Syntax validation and linting
```shell
$ uv run --python 3.14 --with ansible-core ansible-playbook ./ansible/playbooks/install_vector.yaml --syntax-check
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

Example
```shell
$ ansible-playbook --check --diff -i ansible/inventory/linux_hosts.yaml ansible/playbooks/install_vector.yaml -e "vm_hosts=grafana"

PLAY [Install vector.dev on the given servers] ********************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [grafana]

TASK [Install prerequisites packages] *****************************************************************************************
The following additional packages will be installed:
  libice6 libsm6 libxmu6 libxt6t64 x11-common
The following NEW packages will be installed:
  libice6 libsm6 libxmu6 libxt6t64 x11-common xclip
0 upgraded, 6 newly installed, 0 to remove and 1 not upgraded.
changed: [grafana]

PLAY RECAP ********************************************************************************************************************
grafana                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


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
