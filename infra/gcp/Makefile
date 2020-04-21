# configs := $(filter-out variables, $(basename $(wildcard *.json)))
# commands := validate inspect build fix
# packer_build_opts := -var-file=variables.json -parallel=false -force
# builds_dir := builds
# vm_dir := ~/vm

TOOLS = terraform gcloud gsutil
$(foreach exec,$(TOOLS), $(if $(shell which $(exec)),,$(error "No $(exec) in PATH")))

# ifdef DEBUG
# # Enable packer debug logging
# PACKER_LOG := 1
# PACKER_LOG_PATH := /tmp/packer-debug
# ANSIBLE_STRATEGY := debug
# export PACKER_LOG PACKER_LOG_PATH ANSIBLE_STRATEGY
# ifeq ($(DEBUG),step)
# packer_build_opts := $(packer_build_opts) -debug 
# endif
# endif

# Call out rules that don't generate output
.PHONY: env check clean destroy apply all email \
  $(commands) $(foreach command, $(commands), $(addprefix $(command)-,$(configs))) \

check:
	@echo Using billing account ${TF_VAR_billing_account} with project ${TF_VAR_project_id}.
	@echo Using credentials at ${TF_VAR_gcp_credentials}.
	@echo Storing state in gcp bucket ${TF_VAR_gcp_bucket} in region ${TF_VAR_gcp_region}.
	@terraform version

clean: check
	@rm -f terraform.plan

cleaner: clean
	@rm -rf .terraform/

init: check
	@gcloud auth activate-service-account --key-file ${TF_VAR_gcp_credentials}
	@terraform init

%.tf:
	@echo terraform fmt $*

terraform.plan: $(wildcard *.tf)
	@terraform plan --out terraform.plan

apply: terraform.plan
	@terraform apply terraform.plan
	@echo "Plan successfully applied, deleting old plan.."
	@rm terraform.plan

destroy:
	@terraform destroy -force 

all: apply
	@gcloud container clusters get-credentials cloudflow-services --region ${TF_VAR_gcp_region}

email: 
	@cat ${TF_VAR_gcp_credentials} | jq -r .client_email

print-%: 
	@echo $*=$($*)


# @gcloud projects create ${TF_VAR_project_id} --name="Lightbend Cloudflow" 

# @gcloud iam service-accounts create terraform --display-name "Terraform Operator" \
# 	--description "Terraform Operator"
# gcloud iam service-accounts keys create $TF_VAR_gcp_credentials \
# 	--iam-account terraform@$TF_VAR_project_id.iam.gserviceaccount.com

setup:
	@for role in roles/viewer roles/storage.admin roles/compute.admin roles/container.admin roles/iam.serviceAccountUser ; do \
		gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
			--member serviceAccount:$(shell cat ${TF_VAR_gcp_credentials} | jq -r .client_email) \
			--role $$role ; \
	done
	@for api in cloudresourcemanager.googleapis.com cloudbilling.googleapis.com iam.googleapis.com compute.googleapis.com serviceusage.googleapis.com container.googleapis.com ; do \
		gcloud services enable $$api ; \
	done

  	# @gsutil mb -p ${TF_VAR_project_id} -l ${TF_VAR_gcp_region} -c Standard -b on gs://${TF_VAR_gcp_bucket}
