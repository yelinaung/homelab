# CLAUDE.md

This file contains shared instructions for coding agents working in this repository.

## Project Overview

This homelab uses Terraform for Proxmox VMs and containers, Cloudflare DNS, and Tailscale settings; Ansible for host configuration; and Packer for Ubuntu VM templates. CI runs on GitHub, GitLab, and Forgejo.

## Architecture

- **Proxmox (`proxmox/`)**: VM definitions use `vm_<name>.tf`; containers use `lxc_<name>.tf`.
  - `modules/vm_module/` manages existing VMs with deliberate lifecycle exclusions. Preserve these unless changing their ownership is part of the task.
  - `modules/vm_clone_module/` manages template clones with cloud-init; `vm_sample_docker.tf` is a disabled example (`count = 0`).
  - Cloud-init templates live in `proxmox/templates/`.
- **Cloudflare (`cloudflare/`)**: DNS records come from encrypted `dns.sops.yaml`.
- **Tailscale (`tailscale/`)**: Manages tailnet settings and contacts.
- **Ansible (`ansible/`)**: Playbooks live in `playbooks/`, local roles in `roles/`, and inventories in `inventory/` (`linux_hosts.yaml`, `desktop.yaml`, `mac.yaml`). Monitoring configuration includes VictoriaMetrics, Vector, and ClickStack.
- **Packer (`proxmox/packer/`)**: Builds an Ubuntu 24.04 golden template from the base cloud-image template. See `proxmox/README.md` for the image workflow.
- **CI images**: `runners/github/` builds the GitHub runner; `runners/gitlab/` builds the GitLab job image with Terraform, tflint, mise, SOPS, age, and yq; `.forgejo/ci.Dockerfile` defines the Forgejo CI image.
- **Dashboards (`dashboards/`)**: Stores Proxmox monitoring dashboard JSON.

## Tooling and Configuration

- Run mise tasks from the repository root; each Terraform task selects its own working directory.
- `mise.toml` is the source of truth for task names, environment inputs, and tool versions. Use `mise tasks ls` to list tasks.
- Terraform requires >= 1.10.0. Provider pins live in each root's `main.tf` and module `init.tf` files; lock files record selected versions. Read those files instead of relying on version numbers in prose.
- Proxmox and Tailscale load tracked `config.auto.tfvars` for non-secret configuration. Supply credentials through ignored `secrets.auto.tfvars` or `TF_VAR_*` environment variables. The mise tasks do **not** pass `-var-file=values.tfvars`; Terraform does not auto-load that filename.
- All three Terraform roots use GitLab HTTP remote state. Local backend access needs `TF_HTTP_USERNAME` and `TF_HTTP_PASSWORD`; GitLab CI supplies job-token authentication.
- `plan-dns` decrypts `cloudflare/dns.sops.yaml` with SOPS/age and writes ignored `cloudflare/dns.auto.tfvars.json` using yq. It needs an age identity (for example, `SOPS_AGE_KEY`). `plan-dns` and `apply-dns` load `CLOUDFLARE_API_TOKEN` from `cloudflare/.env` when present, or use the environment.
- Never commit plaintext credentials, decrypted DNS variables, state, saved plans, or age private keys. Keep DNS edits SOPS-encrypted and follow `.sops.yaml`.

## Terraform Commands

Use environment assignments **before** the command for task inputs, not `module=...` arguments after the task name. `MODULE` accepts a Terraform resource or module address. Use targeted plans only for intentional partial operations.

```bash
mise run init
mise run plan                 # Saves proxmox/output.out
mise run apply                # Applies that saved plan
mise run fmt
mise run lint

MODULE='<target>' mise run plan-module
MODULE='<target>' mise run apply-module
MODULE='<target>' mise run plan-and-apply-module
mise run ls-state
MODULE='<target>' mise run rm-state
MODULE='<target>' ID='<resource_id>' mise run import
```

Cloudflare and Tailscale have separate roots and saved `output.out` plans:

```bash
mise run init-dns
mise run plan-dns
mise run apply-dns
mise run fmt-dns

mise run init-tailscale
mise run plan-tailscale
mise run apply-tailscale
mise run fmt-tailscale
mise run lint-tailscale
mise run ls-state-tailscale
MODULE='<target>' ID='<resource_id>' mise run import-tailscale
MODULE='<target>' mise run rm-state-tailscale
```

## Ansible Commands

Install dependencies with `mise run install-ansible-deps`. This creates `.venv` with Python 3.14 and installs Ansible, linters, Mitogen, and the roles/collections in `ansible/requirements.yml`. Activate `.venv` or prepend `.venv/bin` to `PATH` before running the `playbook` task, which invokes `ansible-playbook` from `PATH`.

Always set `PLAYBOOK` and `INVENTORY` explicitly, without `.yaml`. The current defaults (`apt_ubuntu_vms` and `hosts`) have no matching files. Set `VM_HOSTS` deliberately for playbooks that use it. SSH keys and trusted host keys must be configured; `ansible/ansible.cfg` enables host-key checking.

```bash
PLAYBOOK=install_node_exporter INVENTORY=linux_hosts VM_HOSTS=cloud-gateway-fiber mise run playbook
```

`BECOME=true` adds `--ask-become-pass`; privilege escalation is defined by the playbook. Optional inputs include `EXTRA_VARS`, `ANSIBLE_VERBOSITY`, and `MITOGEN=true`. The `playbook` task selects `ansible/ansible.cfg` automatically.

## Validation and Safety

For a documentation-only change, check referenced tasks/paths and run `git diff --check`. For infrastructure changes, validate the affected root or playbook before considering a live plan or deployment.

```bash
# Local Terraform checks (substitute cloudflare or tailscale as needed)
terraform -chdir=proxmox fmt -check -recursive
terraform -chdir=proxmox init -backend=false
terraform -chdir=proxmox validate

# Single playbook: syntax check, ansible-lint, and yamllint
ANSIBLE_CONFIG=ansible/ansible.cfg PLAYBOOK=apt_update_upgrade \
  mise run test-ansible
mise run lint-ansible

# Repository hooks: whitespace, YAML, gitleaks, Terraform fmt/Trivy/validate
pre-commit run --all-files
```

- Terraform plans contact live services and may lock remote state. `test-ansible-diff` uses `--check --diff` but still connects to inventory hosts; it is not an offline lint check.
- Obtain explicit approval before applying infrastructure, importing/removing remote state, building templates on Proxmox, running host-changing playbooks, or deploying/reloading services. `plan-and-apply-module` and `deploy-vicky-config` make live changes.
- `mise run push-all` rebases the current branch from the `github` remote with autostash, then pushes to **every configured remote**. Use it only when that scope is authorized.
- Keep changes scoped. Do not run provider upgrades, broad formatting, or all-remote pushes as incidental cleanup.
