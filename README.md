# Homelab

[![Main](https://github.com/yelinaung/homelab/actions/workflows/main.yaml/badge.svg)](https://github.com/yelinaung/homelab/actions/workflows/main.yaml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/yelinaung/homelab/main.svg)](https://results.pre-commit.ci/latest/github/yelinaung/homelab/main)

### GitHub Actions Runner

This repository contains a custom GitHub Actions runner Docker image with `uv` and the latest Node.js pre-installed. The image is built and pushed to `ghcr.io` using a GitHub Actions workflow.

To use the custom runner, you can pull the image from `ghcr.io/yelinaung/homelab/github-runner:latest`.

### Terraform


### Anisble Configs and Playbook for the Homelab

### Role Used

- Jeff Geerling's [node exporter role](https://github.com/geerlingguy/ansible-role-node_exporter)
    - Make sure to install first by
    ```bash
    $ ansible-galaxy install geerlingguy.node_exporter
    ```

#### Documenetation

- [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- [Ansible apt module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
