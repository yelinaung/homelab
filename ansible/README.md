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

## Independent alerting with Grafana visibility

`playbooks/install_alerting.yaml` installs vmalert and Prometheus Alertmanager on
`vicky`, applies the existing `install_vicky.yaml` playbook with a vmalert API
proxy, and provisions two additional data sources on `grafana`. Grafana does not
evaluate these rules or send their notifications. Its existing data sources and
dashboards are left unchanged.

- Edit rules and Telegram routing in `playbooks/vars/alerting.yaml`.
- Edit the stable Tailscale address in `inventory/group_vars/all/alerting.yaml`.
- vmalert listens on loopback port 9431. Alertmanager listens only on Vicky's
  Tailscale address, port 9093; clustering is disabled. Tailnet access policies
  must permit Grafana to reach it and restrict access to trusted clients, since
  the API can create silences and has no additional authentication.
- Grafana's **Homelab alerts** data source shows data source-managed rules and
  their pending/firing states in Alerting. **Homelab Alertmanager** supports
  silences; contact points and notification policies are read-only in Grafana.
- vmalert writes alert state to VictoriaMetrics and restores it on restart.
  These series are not Grafana's built-in alert-history database.

Starter rules evaluate every minute: scrape failures for 3 minutes, disk space
below 15% for 15 minutes or below 5% for 5 minutes, and available memory below
10% for 10 minutes. Disk rules exclude read-only and common temporary filesystems.
CPU usage above 90% produces a warning after 5 minutes, using a 5-minute rate
averaged across all cores per host. Usage is non-idle time (including I/O wait);
a single saturated core does not trigger unless the host-wide average exceeds 90%.
Critical disk alerts suppress warnings for the same filesystem. Telegram receives
firing and resolved notifications, grouped by alert name and instance, with a
4-hour repeat interval. Review intentionally sleeping hosts before deployment.
Messages use 🚨 for unreachable scrape targets, 🔴 for critical alerts, 🟠 for
warnings, 🔵 for information, and ✅ for recovery. Each alert carries its own
indicator so mixed-severity or partially resolved groups remain clear.

### Validate without deploying

Install the pinned requirements with `mise run install-ansible-deps`, then run:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg PLAYBOOK=install_alerting mise run test-ansible
```

This syntax/lint check does not connect to the inventory hosts and needs no
Telegram credentials. Both upstream roles also validate rendered configuration
with their own binaries during deployment (`vmalert-prod -dryRun` and
`amtool check-config`). A first-install `--check` run cannot fully validate
files against binaries that are not installed yet.

### Deploy only after approval

Create the Telegram bot through BotFather, add it to the destination chat, and
obtain the numeric chat ID (keep the minus sign for a group). Supply credentials
through the controller's environment, not Git, CLI extra-vars, or chat messages.
For an interactive Bash session:

```bash
read -rsp 'Telegram bot token: ' TELEGRAM_BOT_TOKEN; echo
read -rp 'Telegram chat ID: ' TELEGRAM_CHAT_ID
export TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID
PATH="$PWD/.venv/bin:$PATH" PLAYBOOK=install_alerting INVENTORY=linux_hosts \
  VM_HOSTS=vicky mise run playbook
unset TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID
```

The playbook targets `vicky` and `grafana`; do not override `VM_HOSTS` to another
host. Add `BECOME=true` if sudo requires a password. The token is written to
`/etc/homelab-alerting/telegram-bot-token` with mode `0640`, owned by
`root:alertmanager`, inside a `0750` directory. Token writes hide log output and
diffs. Alertmanager reads the token file for each notification, including after
rotation; the main configuration contains only its path and the chat ID.

Deployment starts the new services and may restart VictoriaMetrics and Grafana
when their configuration changes. It reapplies the complete existing VictoriaMetrics
playbook, including its scrape configuration. Applying `install_vicky.yaml` alone
also configures the proxy, so deploy the full alerting playbook first.

After approval and deployment, check the service status, VictoriaMetrics'
`/api/v1/rules`, and the Grafana Alerting page. Verify a temporary test alert's
firing and recovery messages in Telegram before relying on delivery. A Grafana
outage does not stop alerts, but loss of Vicky, VictoriaMetrics, or internet access
can. A missing scrape series is not the same as `up == 0`; these starter rules
do not detect every missing target or monitoring failure. Add an external
heartbeat check for whole-stack outages.
