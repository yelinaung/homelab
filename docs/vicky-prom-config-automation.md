# VictoriaMetrics (`vicky`) Scrape Configuration Automation

This document outlines the architecture and implementation plan to automate the Prometheus scrape configuration (`prom_config.yaml`) for the VictoriaMetrics (`vmsingle`) instance running on the `vicky` Proxmox VM (`proxmox/vm_vicky.tf`).

---

## 1. Overview & Objectives

### Current State
* **Infrastructure**: VM `vicky` (VM ID `113`) is provisioned on Proxmox node `homelab2` via Terraform in `proxmox/vm_vicky.tf`.
* **Software Provisioning**: VictoriaMetrics is installed via Ansible role `victoriametrics.cluster.vmsingle` in `ansible/playbooks/install_vicky.yaml`.
* **Current Limitations**:
  1. **Deployment Gap**: VictoriaMetrics is launched with `"promscrape.config": /etc/victoria-metrics/prom_config.yaml`, but the scrape configuration only existed on the live `vicky` host and was not managed in the repository or deployed by Ansible.
  2. **Fragile Target Tracking**: Targets in `prom_config.yaml` use a mixture of Tailscale IPs (`100.x.y.z`) and hostnames, with custom instance labels (e.g. `yankee-proxmox`, `cadvisor_bravo`) that existing Grafana dashboards rely upon.
  3. **First-run Ordering**: The `victoriametrics.cluster.vmsingle` role configures and enables the systemd unit, then flushes its `Restart VictoriaMetrics service` handler after the `roles` section completes. If `/etc/victoria-metrics/prom_config.yaml` is not created before the role's handler fires, the service fails to start.
  4. **Lack of Validation**: Modifying scrape configs manually risks deploying malformed YAML or unsupported scraper parameters to production.

### Goals
1. **Explicit Target Modeling**: Explicitly declare monitoring intent in Ansible inventory without assuming or inferring roles from unrelated attributes (such as Docker Compose).
2. **First-run Resilience (`pre_tasks`)**: Deploy the configuration as `root:root` `0644` in `pre_tasks` so it is in place before the role's service restart handler executes, without flipping ownership across `pre_tasks` and `post_tasks`.
3. **Pre-deployment Validation**: Assert that the rendered template produces a valid YAML mapping with non-empty `scrape_configs` on the Ansible controller, and run VictoriaMetrics' native `-promscrape.config.dryRun` remotely when the binary is installed.
4. **Automatic Config Reloading**: Add `"promscrape.configCheckInterval": 30s` to `victoriametrics_service_args`. *(Note: Adding this flag modifies the systemd unit on first deploy, which triggers a one-time service restart; all subsequent scrape config edits are picked up within 30s without restarting the service or needing an HTTP handler).*
5. **Operational Simplicity**: Use the repository's native `mise` tasks (`PLAYBOOK=install_vicky VM_HOSTS=vicky mise run test-ansible-diff`, `mise run deploy-vicky-config`).

---

## 2. Inventory & Target Modeling

### Why Heuristic Discovery is Avoided
Inferring targets dynamically (such as looping over `groups['all']` or checking `compose_dirs`) changes monitoring behavior unexpectedly:
- **`groups['all']`**: Falsely assumes Node Exporter runs everywhere, inadvertently adding hosts like `beszel-hub`, `miniflux`, and `sportzx`, while changing existing Tailscale IPs to hostnames that may not resolve or route properly from `vicky`.
- **`compose_dirs`**: Is not an indicator of cAdvisor. It would erroneously add `readeck` and `miniflux`, while dropping existing targets like `playground-bravo` and `dokku1`.
- **Label Drift**: Existing dashboards depend on specific `instance` labels (e.g. `cadvisor_bravo`, `andre-alpha-proxmox`, `forgejo-lxc`, `ucg-fiber`).

### Solution: Explicit Monitoring Inventory

Define explicit target lists and labels in `ansible/inventory/group_vars/all/monitoring.yaml` (placed alongside `ansible/inventory/linux_hosts.yaml` so Ansible reliably loads it across all playbooks). This preserves exact scrape addresses and dashboard labels:

```yaml
# ansible/inventory/group_vars/all/monitoring.yaml
---
monitoring_node_exporter_targets:
  - address: "yla-jp-1:9100"
    instance: "yla-jp-1"
  - address: "yla-jp-2:9100"
    instance: "yla-jp-2"
  - address: "100.65.204.35:9100"
    instance: "homelab1"
  - address: "100.91.69.16:9100"
    instance: "homelab2"
  - address: "100.126.212.39:9100"
    instance: "homelab3"
  - address: "100.108.224.32:9100"
    instance: "desktop"
  - address: "100.108.10.144:9100"
    instance: "playground-bravo"
  - address: "100.116.235.43:9100"
    instance: "yankee-proxmox"
  - address: "100.104.167.118:9100"
    instance: "andre-alpha-proxmox"
  - address: "100.106.238.90:9100"
    instance: "grafana-proxmox"
  - address: "100.85.250.52:9100"
    instance: "umami-proxmox"
  - address: "vicky:9100"
    instance: "vicky-proxmox"
  - address: "100.95.92.76:9100"
    instance: "influx-proxmox"
  - address: "100.116.4.67:9100"
    instance: "vultr-sandbox"
  - address: "immich:9100"
    instance: "immich"
  - address: "forgejo:9100"
    instance: "forgejo-lxc"
  - address: "dokku1:9100"
    instance: "dokku1"
  - address: "readeck:9100"
    instance: "readeck-lxc"
  - address: "navidrome:9100"
    instance: "navidrome"
  - address: "cloud-gateway-fiber:9100"
    instance: "ucg-fiber"
  - address: "clickstack:9100"
    instance: "clickstack"

monitoring_cadvisor_targets:
  - address: "100.85.250.52:8080"
    instance: "cadvisor_umami"
  - address: "100.108.10.144:8080"
    instance: "cadvisor_bravo"
  - address: "forgejo:8080"
    instance: "cadvisor_forgejo"
  - address: "unpoller:8080"
    instance: "cadvisor_unpoller"
  - address: "immich:8080"
    instance: "cadvisor_immich"
  - address: "dokku1:8080"
    instance: "cadvisor_dokku1"
  - address: "navidrome:8080"
    instance: "cadvisor_navidrome"
```

*Note: When a new VM is provisioned in Terraform, adding monitoring for it is as simple as adding an entry to this file.*

---

## 3. Template & Playbook Implementation

### Step 1: Jinja2 Template (`ansible/playbooks/templates/prom_config.yaml.j2`)

```yaml
scrape_configs:
  - job_name: 'vicky_logs'
    metrics_path: /metrics
    scrape_interval: 10s
    static_configs:
      - targets:
          - 'vicky:9428'
        labels:
          instance: 'vicky-logs'

  - job_name: 'nodes'
    metrics_path: /metrics
    scrape_interval: 10s
    static_configs:
{% for target in monitoring_node_exporter_targets %}
      - targets:
          - '{{ target.address }}'
        labels:
          instance: '{{ target.instance }}'
{% endfor %}

  - job_name: 'cadvisor'
    metrics_path: /metrics
    scrape_interval: 10s
    static_configs:
{% for target in monitoring_cadvisor_targets %}
      - targets:
          - '{{ target.address }}'
        labels:
          instance: '{{ target.instance }}'
{% endfor %}

  - job_name: 'unifipoller'
    scrape_interval: 30s
    static_configs:
      - targets: ['unpoller:9130']

  - job_name: 'pve-exporter'
    metrics_path: /pve
    static_configs:
      - targets: ['192.168.1.206']
        labels:
          exporter_address: '192.168.1.55:9221'
      - targets: ['192.168.1.207']
        labels:
          exporter_address: '192.168.1.170:9221'
      - targets: ['192.168.1.208']
        labels:
          exporter_address: '192.168.1.254:9221'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - source_labels: [exporter_address]
        target_label: __address__
```

---

### Step 2: Playbook with Pre-tasks & Validation (`ansible/playbooks/install_vicky.yaml`)

To ensure idempotent execution across both clean bootstrapping and routine updates:
1. **Controller-Side Assertion**: `pre_tasks` renders the template on the controller, parses it with `from_yaml`, and asserts `scrape_configs` is a non-empty list. This fails fast before touching the host and does not require PyYAML on the target node.
2. **First-Run Ordering & Stable Ownership**: `pre_tasks` creates `/etc/victoria-metrics` (`root:root`, `0755`) and writes `prom_config.yaml` (`root:root`, `0644`) before the `victoriametrics.cluster.vmsingle` role executes. Because the VictoriaMetrics systemd unit runs with `ProtectSystem=full` (`/etc` mounted read-only) and only requires read access, keeping `root:root` `0644` permanently avoids ownership flip-flopping between `pre_tasks` and `post_tasks`.
3. **Remote VictoriaMetrics Validation**: When `/usr/local/bin/victoria-metrics-prod` exists on the target, the `template` task validates the rendered config against VictoriaMetrics' strict parser using `-promscrape.config.dryRun`.
4. **No Fragile Pre-task Handlers**: Handlers notified in `pre_tasks` flush at the end of `pre_tasks` (before `roles` run), which would fail with `connection refused` on a fresh host where VictoriaMetrics is not yet installed. Relying on `"promscrape.configCheckInterval": 30s` avoids pre-role handler failures while automatically reloading config changes within 30 seconds.

```yaml
---
- name: Install/Update VictoriaMetrics (Vicky) Single
  hosts: '{{ vm_hosts | default("vicky") }}'
  gather_facts: true
  become: true

  vars:
    victoriametrics_system_user: victoriametrics
    victoriametrics_system_group: "{{ victoriametrics_system_user }}"
    victoriametrics_version: "v1.151.0"
    victoriametrics_data_dir: "/var/lib/victoria-metrics/"
    victoriametrics_retention_period_months: "12"
    victoriametrics_self_scrape_interval: "30s"
    victoriametrics_service_args:
      selfScrapeInterval: 30s
      maxConcurrentInserts: 2048
      retentionPeriod: 365d
      inmemoryDataFlushInterval: 1s
      "search.maxUniqueTimeseries": 900000
      "insert.maxQueueDuration": 30s
      "promscrape.config": /etc/victoria-metrics/prom_config.yaml
      "promscrape.configCheckInterval": 30s
      storageDataPath: /var/lib/victoria-metrics/
      graphiteListenAddr: :2003

  pre_tasks:
    - name: Validate rendered scrape configuration on controller
      vars:
        _validated_config: "{{ lookup('ansible.builtin.template', 'templates/prom_config.yaml.j2') | from_yaml }}"
      ansible.builtin.assert:
        that:
          - _validated_config is mapping
          - _validated_config.scrape_configs is defined
          - _validated_config.scrape_configs | length > 0
        fail_msg: "Rendered prom_config.yaml is missing non-empty scrape_configs"

    - name: Ensure VictoriaMetrics configuration directory exists
      ansible.builtin.file:
        path: /etc/victoria-metrics
        state: directory
        owner: root
        group: root
        mode: "0755"

    - name: Deploy VictoriaMetrics scrape configuration
      ansible.builtin.template:
        src: templates/prom_config.yaml.j2
        dest: /etc/victoria-metrics/prom_config.yaml
        owner: root
        group: root
        mode: "0644"
        validate: >-
          sh -c '! test -x /usr/local/bin/victoria-metrics-prod ||
          /usr/local/bin/victoria-metrics-prod -promscrape.config.dryRun -promscrape.config="$1"' -- %s

  roles:
    - victoriametrics.cluster.vmsingle
```

---

## 4. Service Discovery: Supported Patterns in VictoriaMetrics

> **Note on `proxmox_sd_configs`:**
> Neither Prometheus (`promtool`) nor VictoriaMetrics (`promscrape`) supports a `proxmox_sd_configs` field. Both reject it as an unknown configuration field.

If dynamic auto-discovery is desired in the future without updating Ansible variables, use one of VictoriaMetrics' supported mechanisms:

### Option A: File-Based Service Discovery (`file_sd_configs`) — Recommended
VictoriaMetrics supports watching JSON/YAML target files:

```yaml
scrape_configs:
  - job_name: 'dynamic_nodes'
    file_sd_configs:
      - files:
          - '/etc/victoria-metrics/targets/*.json'
```

*File check frequency*: VictoriaMetrics checks for changes based on the CLI flag `-promscrape.fileSDCheckInterval` (e.g. set `"promscrape.fileSDCheckInterval": "30s"` in `victoriametrics_service_args`).

A scheduled script (e.g. cron or systemd timer) or CI pipeline can query the Proxmox API or Tailscale API and drop a JSON file into `/etc/victoria-metrics/targets/nodes.json`:
```json
[
  {
    "targets": ["100.116.235.43:9100"],
    "labels": {
      "instance": "yankee-proxmox",
      "environment": "homelab"
    }
  }
]
```

### Option B: HTTP Service Discovery (`http_sd_configs`)
VictoriaMetrics queries an internal HTTP endpoint returning targets in standard Prometheus HTTP-SD format:
```yaml
scrape_configs:
  - job_name: 'proxmox_vms'
    http_sd_configs:
      - url: 'http://sd-adapter.local:8080/targets'
```

*Note on polling interval*: VictoriaMetrics does not accept `refresh_interval` inside `http_sd_configs`. The check interval is configured globally via the service argument:
`"promscrape.httpSDCheckInterval": "1m"`.

---

## 5. Operations & Developer Workflow

### 1. Add Shortcut Task in `mise.toml`
```toml
[tasks.deploy-vicky-config]
description = "Deploy and reload VictoriaMetrics scrape configuration on Vicky"
raw = true
run = "PLAYBOOK=install_vicky INVENTORY=linux_hosts VM_HOSTS=vicky BECOME=true mise run playbook"
```

### 2. Routine Workflow

When adding a new VM or modifying scrape targets:
1. Edit `ansible/inventory/group_vars/all/monitoring.yaml`.
2. Run the repository's existing dry-run task:
   ```bash
   PLAYBOOK=install_vicky VM_HOSTS=vicky mise run test-ansible-diff
   ```
   *(Or run manually via `ansible-playbook -i ansible/inventory/linux_hosts.yaml ansible/playbooks/install_vicky.yaml --check --diff -e "vm_hosts=vicky"`)*
3. Deploy:
   ```bash
   mise run deploy-vicky-config
   ```
4. Confirm target health:
   ```bash
   curl -s http://vicky:8428/api/v1/targets | jq .
   ```
