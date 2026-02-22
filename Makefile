TERRAFORM_DIR = proxmox
CLOUDFLARE_DIR = cloudflare
GREEN  = \033[0;32m
YELLOW = \033[0;33m
NC     = \033[0m
.PHONY: plan apply plan_and_generate fmt init init-and-upgrade import test-ansible test-ansible-diff lint-ansible push \
	plan-dns apply-dns init-dns fmt-dns

plan:
	cd $(TERRAFORM_DIR) && terraform plan -var-file=values.tfvars -out=output.out
plan-module:
	cd $(TERRAFORM_DIR) && terraform plan -var-file=values.tfvars -out=$(module)_output.out -target=$(module)
plan_and_generate:
	cd $(TERRAFORM_DIR) && terraform plan -var-file=values.tfvars -generate-config-out=generated.tf
apply:
	cd $(TERRAFORM_DIR) && terraform apply output.out
apply-module:
	cd $(TERRAFORM_DIR) && terraform apply $(module)_output.out
plan-and-apply-module:
	cd $(TERRAFORM_DIR) && \
		terraform plan -var-file=values.tfvars -out=$(module)_output.out -target=$(module) && \
		terraform apply $(module)_output.out
fmt:
	cd $(TERRAFORM_DIR) && terraform fmt -recursive
init:
	cd $(TERRAFORM_DIR) && terraform init
init-and-upgrade:
	cd $(TERRAFORM_DIR) && terraform init -upgrade
import:
	cd $(TERRAFORM_DIR) && terraform import -var-file=values.tfvars $(module) $(id)
rm-state:
	cd $(TERRAFORM_DIR) && terraform state rm $(module)
ls-state:
	cd $(TERRAFORM_DIR) && terraform state list
lint:
	cd $(TERRAFORM_DIR) && tflint --recursive -f compact --color

plan-dns:
	cd $(CLOUDFLARE_DIR) && terraform plan -var-file=values.tfvars -out=output.out
apply-dns:
	cd $(CLOUDFLARE_DIR) && terraform apply output.out
init-dns:
	cd $(CLOUDFLARE_DIR) && terraform init
fmt-dns:
	cd $(CLOUDFLARE_DIR) && terraform fmt -recursive
push:
	@set -e; \
	branch="$$(git rev-parse --abbrev-ref HEAD)"; \
	if [ "$$branch" = "HEAD" ]; then \
		echo "Detached HEAD; please checkout a branch before pushing."; \
		exit 1; \
	fi; \
	remotes="$$(git remote)"; \
	if [ -z "$$remotes" ]; then \
		echo "No git remotes configured."; \
		exit 1; \
	fi; \
	for remote in $$remotes; do \
		echo "Pushing $$branch to $$remote..."; \
		git push "$$remote" "$$branch"; \
	done

playbook ?= apt_ubuntu_vms
inventory ?= hosts
export ANSIBLE_CONFIG = ./ansible/ansible.cfg
ANSIBLE_CMD = ansible-playbook ./ansible/playbooks/$(playbook).yaml -i ./ansible/inventory/$(inventory).yaml

# Optional flags
vm_hosts ?=
become ?= false

run:
ifeq ($(become), true)
ifneq ($(vm_hosts),)
	$(ANSIBLE_CMD) --ask-become-pass --extra-vars "vm_hosts=$(vm_hosts)"
else
	$(ANSIBLE_CMD) --ask-become-pass
endif
else
ifneq ($(vm_hosts),)
	$(ANSIBLE_CMD) --extra-vars "vm_hosts=$(vm_hosts)"
else
	$(ANSIBLE_CMD)
endif
endif
help:
	@echo "Usage: make run [playbook=<playbook_name>] [inventory=<inventory_file>] [become=<true/false>] [extra_vars=<extra_vars>]"
	@echo "  playbook: the name of the playbook to run (default: example)"
	@echo "  inventory: the name of the inventory file to use (default: hosts)"
	@echo "  become: whether to ask for become password (default: false)"
	@echo "  extra_vars: extra variables to pass to the playbook (default: --extra-vars \"vm_hosts=desktop\")"

UV_RUN_WITH = uv run --python 3.14 --with
test-ansible:
	@echo "$(GREEN)Running Ansible Syntax check$(NC)"
	$(UV_RUN_WITH) ansible-core ansible-playbook ansible/playbooks/$(playbook).yaml -i ansible/inventory/linux_hosts.yaml --syntax-check

	@echo "$(GREEN)Running Ansible Lint$(NC)"
	$(UV_RUN_WITH) ansible-lint ansible-lint ansible/playbooks/$(playbook).yaml

	@echo "$(GREEN)Running YAML Lint$(NC)"
	$(UV_RUN_WITH) yamllint yamllint ansible/playbooks/$(playbook).yaml

lint-ansible:
	@echo "$(GREEN)Running Ansible Syntax check on all playbooks$(NC)"
	@for playbook in ansible/playbooks/*.yaml; do \
		echo "Checking $$playbook..." && \
		$(UV_RUN_WITH) ansible-core ansible-playbook $$playbook -i ansible/inventory/linux_hosts.yaml --syntax-check || exit 1; \
	done

	@echo "$(GREEN)Running Ansible Lint$(NC)"
	$(UV_RUN_WITH) ansible-lint ansible-lint ansible/

	@echo "$(GREEN)Running YAML Lint$(NC)"
	$(UV_RUN_WITH) yamllint yamllint ansible/playbooks/*.yaml

test-ansible-diff:
	@echo "$(GREEN)Running Ansible Diff$(NC)"
	$(UV_RUN_WITH) ansible-core ansible-playbook ansible/playbooks/$(playbook).yaml \
		--inventory ansible/inventory/linux_hosts.yaml \
		--check --diff -e "vm_hosts=$(vm_hosts)"
