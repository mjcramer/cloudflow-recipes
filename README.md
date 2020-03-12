# Cloudflow Installation Notes


For deploying cloud services, whenever I’m creating infrastructure, I like everything that I do be codified and versioned, and for this I like to use terraform. As I step through the setup process, I can interatively create and manage my resources, and at any point I can completely trash whatever I’m doing and start over at no cost, because since everything I’ve done is codified, I merely just need to redeploy the configuration to get back to where I was before.


# Set up GCP


Create service account
Instructions for creating service accounts

```bash
export TF_VAR_org_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_VAR_project_name=YOUR_PROJECT_NAME
export TF_VAR_gcp_credentials=FILE_TO_WRITE_CREDENTIALS
```

export TF_ADMIN=$TF_VAR_project_name}-terraform-admin
export TF_CREDS=~/.config/gcloud/TF_VAR_project_name}-terraform-admin.json

Create a new configuration for the gcloud tool

```bash
gcloud config configurations create cloudflow-operator
```

Create new project and link to proper billing account

```bash
gcloud projects create $TF_VAR_project_name \
  --organization $TF_VAR_org_id \ # omit if you are creating this under a user account
  --set-as-default

gcloud projects create $TF_VAR_project_name \
  --set-as-default

gcloud beta billing projects link $TF_VAR_project_name \
  --billing-account $TF_VAR_billing_account
```

Create the terraform service account

```bash
gcloud iam service-accounts create terraform \
  --display-name "Terraform Operator"

gcloud iam service-accounts keys create $TF_VAR_gcp_credentials \
  --iam-account terraform@$TF_VAR_project_name.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $TF_VAR_project_name \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding $TF_VAR_project_name \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_name \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/compute.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_name \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/container.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_name \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
```

Enable the API's for all the services we will be using

```bash
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable container.googleapis.com
```

Grant the service account the ability to create projects and assign billing accounts

```bash
gcloud organizations add-iam-policy-binding $TF_VAR_org_id \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding $TF_VAR_org_id \
  --member serviceAccount:terraform@$TF_VAR_project_name.iam.gserviceaccount.com \
  --role roles/billing.user
```


```bash
gsutil mb -p $TF_VAR_project_name gs://$TF_VAR_project_name
```

```bash
gcloud container clusters get-credentials cloudflow-services --region us-west1 --project $TF_VAR_project_name


```

## Clean up

```
terraform destroy -force

gcloud projects delete $TF_VAR_project_name
gcloud iam service-accounts delete terraform@$TF_VAR_project_name.iam.gserviceaccount.com --quiet


## Create a project

Here we will add our infrastructure components
