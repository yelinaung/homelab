.PHONY: plan apply plan_and_generate output clean

plan:
	cd proxmox && terraform plan -var-file=values.tfvars -out=output.out
plan_and_generate:
	cd proxmox && terraform plan -var-file=values.tfvars -generate-config-out=generated.tf
apply:
	cd proxmox && terraform apply output.out
