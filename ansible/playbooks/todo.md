# Ansible Playbooks Improvement TODO

## Critical Security Issues

- [ ] **CRITICAL:** Fix `add_ssh_key.yaml` - Remove NOPASSWD sudo or restrict it severely
  - Current: `%sudo ALL=(ALL) NOPASSWD: ALL` is a major security risk
  - Fix: Use `%sudo ALL=(ALL) PASSWD: ALL` or restrict to specific commands

- [ ] **CRITICAL:** Fix `install_influxdb.yaml` - Move credentials to Ansible Vault
  - Current: Hardcoded weak password "greatgreatgreat" in plain text
  - Fix: Use `ansible-vault create group_vars/all/vault.yml`

- [ ] **CRITICAL:** Fix `install_vicky.yaml` - Move hardcoded credentials to vault
  - Current: Plain text credentials in playbook
  - Fix: Use Ansible Vault for sensitive data

## High Priority Bugs

- [ ] **HIGH:** Complete `install_vector.yaml` - Currently incomplete
  - Current: Only installs prerequisites, not Vector itself
  - Fix: Add Vector APT repository, package installation, and service configuration

- [ ] **HIGH:** Fix `update_omz.yaml` - Replace placeholder `changed_when` condition
  - Current: Uses `'Example update string'` which will never match
  - Fix: Use actual output check like `'Already up to date' not in omz_update_result.stdout`

- [ ] **HIGH:** Fix `install_nginx.yaml` - Remove duplicate service start tasks
  - Current: Lines 11-14 and 16-18 both start nginx service
  - Fix: Keep one task with `enabled: true` added

- [ ] **HIGH:** Fix `install_vicky.yaml` - Remove duplicate retention settings
  - Current: Conflicting `retention_period_months: 12` and `retentionPeriod: "365d"`
  - Fix: Remove one of the retention settings

## Medium Priority Improvements

- [ ] **MEDIUM:** Add `cache_valid_time: 3600` to apt operations
  - Affects: `apt_update_upgrade.yaml`, `apt_dist_upgrade.yaml`, `install_essentials.yaml`
  - Prevents unnecessary cache updates

- [ ] **MEDIUM:** Add error handling with retries for network operations
  - Affects: All apt operations, external downloads
  - Add: `retries: 3`, `delay: 10`, `until: result is succeeded`

- [ ] **MEDIUM:** Enable `gather_facts: true` where needed
  - Affects: `apt_dist_upgrade.yaml`, `install_zsh.yaml`
  - Needed for multi-OS support

- [ ] **MEDIUM:** Add post-install verification tasks
  - Affects: `install_node_exporter.yaml`, `install_nginx.yaml`, `install_docker.yaml`
  - Use `ansible.builtin.uri` or `ansible.builtin.command` to verify services

- [ ] **MEDIUM:** Add firewall configuration for services
  - Affects: `install_nginx.yaml`, `install_node_exporter.yaml`, `install_vicky_logs.yaml`
  - Add ufw/firewalld rules for opened ports

- [ ] **MEDIUM:** Add `no_log: true` for sensitive operations
  - Affects: `install_tailscale.yaml` (auth key)
  - Prevents credential exposure in logs

## Low Priority Improvements

- [ ] **LOW:** Standardize variable naming across playbooks
  - Some use `vm_hosts`, others don't
  - Standardize on: `hosts: '{{ target_hosts | default("all") }}'`

- [ ] **LOW:** Move package lists to variables
  - Affects: `install_essentials.yaml`
  - Move hardcoded lists to `vars/` or `defaults/` files

- [ ] **LOW:** Add pre-flight checks to playbooks
  - Check Ansible version compatibility
  - Check disk space before upgrades
  - Check for logged-in users before shutdown/reboot

- [ ] **LOW:** Add tags for selective execution
  - Add tags like `['install', 'configure', 'verify']` to tasks

- [ ] **LOW:** Create common handler file
  - Move repeated handlers to `handlers/main.yml`

- [ ] **LOW:** Improve Caddy installation security
  - Use secure location for GPG key (not /tmp)
  - Add checksum verification
  - Add `caddy validate` before restarting

- [ ] **LOW:** Add backup before modifying system files
  - Affects: `add_ssh_key.yaml` (sudoers file)
  - Use `backup: true` parameter

## Service-Specific Improvements

### Docker (`install_docker.yaml`)
- [ ] Add `docker_users` variable for non-root usage
- [ ] Add `docker_daemon_options` for log rotation
- [ ] Add post-task to verify docker is working

### Tailscale (`install_tailscale.yaml`)
- [ ] Add post-task to verify tailscale status
- [ ] Add variables for exit node/subnet routing config

### QEMU Guest Agent (`install_qemu_guest_agents.yaml`)
- [ ] Add service enable/start tasks
- [ ] Add multi-OS support (RHEL/Fedora)
- [ ] Add verification that agent is responding

### Oh My Zsh (`update_omz.yaml`)
- [ ] Add check for zsh as default shell
- [ ] Target specific users instead of all
- [ ] Add proper `become` configuration

### Reboot/Shutdown (`reboot_vms.yaml`, `shutdown_vms.yaml`)
- [ ] Add warning messages before action
- [ ] Add check for logged-in users
- [ ] Make delay configurable via variable
- [ ] Add post-reboot verification with `wait_for_connection`

## Code Organization

- [ ] Create `common.yml` for shared pre_tasks
- [ ] Implement Ansible Vault structure for secrets
- [ ] Add Molecule testing for complex playbooks
- [ ] Document all variables in README or `vars/` files

## Notes

- Total playbooks analyzed: 19
- Priority levels: Critical (immediate action), High (fix soon), Medium (improve when possible), Low (nice to have)
- Most issues are repetitive patterns that can be fixed systematically
