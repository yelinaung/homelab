.PHONY: plan apply destroy output clean

plan:
	cd proxmox && terraform plan -var-file=values.tfvars
apply:
	cd proxmox && terraform apply
