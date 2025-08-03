TERRAFORM_DIR = proxmox
.PHONY: plan apply plan_and_generate fmt init init-and-upgrade import

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
ANSIBLE_CMD = ansible-playbook ./playbooks/$(playbook).yaml -i ./inventory/$(inventory)

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
