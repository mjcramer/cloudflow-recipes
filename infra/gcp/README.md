
# Set up GCP


## Create a new project
Instructions for creating new project

```bash
export TF_VAR_project_id=cloudflow
gcloud projects create $TF_VAR_project_id \
  --set-as-default
```

Alternatively, if you are creating this under an organization...

```bash
gcloud projects create $TF_VAR_project_id \
  --organization $TF_VAR_org_id \
  --set-as-default
```

Link the billing account...

```bash
gcloud beta billing projects link $TF_VAR_project_id \
  --billing-account $TF_VAR_billing_account
```

## Create a service account
Instructions for creating service accounts

Create the terraform service account

```bash
gcloud iam service-accounts create terraform \
  --display-name "Terraform Operator"

gcloud iam service-accounts keys create $TF_VAR_gcp_credentials \
  --iam-account terraform@$TF_VAR_project_id.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $TF_VAR_project_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding $TF_VAR_project_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/compute.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/container.admin

gcloud projects add-iam-policy-binding $TF_VAR_project_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
```


## Generate credentials for service account


```bash
export TF_VAR_org_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_VAR_project_id=YOUR_PROJECT_NAME
export TF_VAR_gcp_credentials=FILE_TO_WRITE_CREDENTIALS
export TF_VAR_gcp_bucket=YOUR_INFRASTRUCTUE_BUCKET
```


## [OPTIONAL] Generate new configuration for gloud
Create a new configuration for the gcloud tool

```bash
gcloud config configurations create cloudflow-operator
```


## Enable the API's for all the services we will be using

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
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding $TF_VAR_org_id \
  --member serviceAccount:terraform@$TF_VAR_project_id.iam.gserviceaccount.com \
  --role roles/billing.user
```


```bash
gsutil mb -p $TF_VAR_project_id gs://$TF_VAR_gcp_bucket

gsutil acl ch \
    -u terraform@$TF_VAR_project_id.iam.gserviceaccount.com:OWNER \
    gs://$TF_VAR_gcp_bucket
gsutil -m acl ch -r \
    -u terraform@$TF_VAR_project_id.iam.gserviceaccount.com:OWNER \
    gs://$TF_VAR_gcp_bucket
```

```bash
gcloud container clusters get-credentials cloudflow-services --region us-west1 --project $TF_VAR_project_id


```

## Clean up

```
terraform destroy -force

gcloud projects delete $TF_VAR_project_id
gcloud iam service-accounts delete terraform@$TF_VAR_project_id.iam.gserviceaccount.com --quiet


## Create a project

Here we will add our infrastructure components


# Open Questions / Problems

1. Is it required that kafka's auto.topic.create be set to true? If it is not, then all topics must be created manually and it does not seem like cloudflow has a process for doing that. 

1. gcloud seems to have some credential problems with docker when it is installed via brew. The reason for this is that brew generally takes care of the symlinnking of binaries from the install location (usually /usr/local/Cellar) to the global path location (usually /usr/local/bin). it expects to find docker-credential-gcr in the path. buyt htis is not avialable because it is installed by glocund after the fact, vi gcloud compontents install docker-0cred-estuif

1. Cannot install kubectl-cloudflow binary on mac becaauise of mac security settings







# Create project 
Record project id

# Create service account 

Select project created in the previous step.
Add following roles:
- role 1 
- role 2

# Create bucket

Create a storage bucket for storing terraform state
Record bucket name
