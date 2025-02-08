TERRAFORM_DIR = proxmox
.PHONY: plan apply plan_and_generate output clean

plan:
	cd $(TERRAFORM_DIR) && terraform plan -var-file=values.tfvars -out=output.out
plan_and_generate:
	cd $(TERRAFORM_DIR) && terraform plan -var-file=values.tfvars -generate-config-out=generated.tf
apply:
	cd $(TERRAFORM_DIR) && terraform apply output.out
fmt:
	cd $(TERRAFORM_DIR) && terraform fmt *.tf
