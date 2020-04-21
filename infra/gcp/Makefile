
TOOLS = terraform gcloud gsutil
$(foreach exec,$(TOOLS), $(if $(shell which $(exec)),,$(error "No $(exec) in PATH")))

# Call out rules that don't generate output
.PHONY: env check clean destroy apply all email \
  $(commands) $(foreach command, $(commands), $(addprefix $(command)-,$(configs))) \

check:
ifndef TF_VAR_billing_account
	$(error TF_VAR_billing_account is undefined)
endif
ifndef TF_VAR_project_id
	$(error TF_VAR_project_id is undefined)
endif
ifndef TF_VAR_gcp_credentials
	$(error TF_VAR_gcp_credentials is undefined)
endif
ifndef TF_VAR_gcp_bucket
	$(error TF_VAR_gcp_bucket is undefined)
endif
ifndef TF_VAR_gcp_region
	$(error TF_VAR_gcp_region is undefined)
endif
ifndef TF_VAR_node_machine_type
	$(error TF_VAR_node_machine_type is undefined)
endif
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

%.tf: check
	@echo terraform fmt $*

terraform.plan: $(wildcard *.tf)
	@terraform plan --out terraform.plan

apply: check terraform.plan
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
