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
