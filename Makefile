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
