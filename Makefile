TERRAFORM_DIR = proxmox
GREEN  = \033[0;32m
YELLOW = \033[0;33m
NC     = \033[0m
.PHONY: plan apply plan_and_generate fmt init init-and-upgrade import test-ansible test-ansible-diff lint-ansible

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

playbook ?= apt_ubuntu_vms
inventory ?= hosts
ANSIBLE_CMD = ansible-playbook ./ansible/playbooks/$(playbook).yaml -i ./ansible/inventory/$(inventory).yaml

# Optional flags
# EXTRA_VARS ?= --extra-vars "vm_hosts=desktop"
vm_hosts ?= ""
extra_vars ?= --extra-vars "vm_hosts=$(vm_hosts)"
become ?= false

run:
ifeq ($(become), true)
	$(ANSIBLE_CMD) --ask-become-pass $(extra_vars)
else
	$(ANSIBLE_CMD)
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
	$(UV_RUN_WITH) ansible-core ansible-playbook ansible/playbooks/$(playbook).yaml --syntax-check

	@echo "$(GREEN)Running Ansible Lint$(NC)"
	$(UV_RUN_WITH) ansible-lint ansible-lint ansible/playbooks/$(playbook).yaml

	@echo "$(GREEN)Running YAML Lint$(NC)"
	$(UV_RUN_WITH) yamllint yamllint ansible/playbooks/$(playbook).yaml

lint-ansible:
	@echo "$(GREEN)Running Ansible Syntax check on all playbooks$(NC)"
	@for playbook in ansible/playbooks/*.yaml; do \
		echo "Checking $$playbook..." && \
		$(UV_RUN_WITH) ansible-core ansible-playbook $$playbook --syntax-check || exit 1; \
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
