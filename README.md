# Cloudflow Installation Notes


For deploying cloud services, whenever I’m creating infrastructure, I like everything that I do be codified and versioned, and for this I like to use terraform. As I step through the setup process, I can interatively create and manage my resources, and at any point I can completely trash whatever I’m doing and start over at no cost, because since everything I’ve done is codified, I merely just need to redeploy the configuration to get back to where I was before.


# Set up GCP


Create service account
Instructions for creating service accounts

```bash
export TF_VAR_org_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_VAR_project_id=YOUR_PROJECT_NAME
export TF_VAR_gcp_credentials=FILE_TO_WRITE_CREDENTIALS
export TF_VAR_gcp_bucket=YOUR_INFRASTRUCTUE_BUCKET
```

export TF_ADMIN=$TF_VAR_project_id}-terraform-admin
export TF_CREDS=~/.config/gcloud/TF_VAR_project_id}-terraform-admin.json

Create a new configuration for the gcloud tool

```bash
gcloud config configurations create cloudflow-operator
```

Create new project and link to proper billing account

```bash
gcloud projects create $TF_VAR_project_id \
  --organization $TF_VAR_org_id \ # omit if you are creating this under a user account
  --set-as-default

gcloud projects create $TF_VAR_project_id \
  --set-as-default

gcloud beta billing projects link $TF_VAR_project_id \
  --billing-account $TF_VAR_billing_account
```

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


# Open Questions

1. Is it required that kafka's auto.topic.create be set to true? If it is not, then all topics must be created manually and it does not seem like cloudflow has a process for doing that. 


A Terraform installer would be beneficial to be used with some integration testing and performance testing.
A description of initial experience in getting deployed would also be helpful

Recipes

1. Schema Transition

  We have deployed an application flow and it is running successfully. At some point we decide to add an additional field to one of the input data structures and redeploy the application, assuming some default value for old data structures that do not have this field present.

1. Topic Data Loss

  In this scenario we have data loss occur in one of our Kafka topics. This occurs in one of two ways:
  1. Some records are lost due to a network partition 
  1. A topic partition is lost because a broker hosting that partition goes down and there is isn't sufficient replication in place to change partitions.

1. Clearing Topic Data / Reset

  In this scenario we clear out the data in a Kafka topic so that the application can be reset.
  
  

## Step by Step Process

1. Write down use case from existing sample app and deploy it. Go over pain points…

2. Come up with a justification for modifying schema, like adding extra outlet for logging or debugging purposes… Make sure that data is in topics as if it was in production for a while. When legacy data matter AND you need to make changes to schema
	1. Avro backward compatible schema, reinterpreting as new schema that has default for fresh field. Changes will be checked by blueprint
	2. What happens if you only change the consumer with compatible change
	3. Blueprint schema should be able to extract schema rom source code and determine if they are compatible
Integration test that switches between different stages of the transition and ensures that it transitions smoothly.


## Possible deliverables
* FAQ from lessons learned
* Handwritten guide of experience
* Code -  deliverable integration tests


## Tools for capturing experience
	* Loom - record screen - upload to cloud
- 