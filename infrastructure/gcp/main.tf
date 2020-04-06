
terraform {
  backend "gcs" {
    # The following parameter sets the service account to be used for terraform state storage. It requires access to the 
    # storage bucket to be used for state object. Since this contains potentially sensitive information, it is better to
    # set the environment variable `GOOGLE_BACKEND_CREDENTIALS` instead. 
    #
    # credentials = "/Users/.gcp/cloudflow-1023-4fd3607819ea.json"
    bucket = "cloudflow-1023b"
    prefix = "terraform/state"
  }
}

# variable "org_id" {
#   description = "The id associated with this organisation"
# }

variable "billing_account" {
  description = "The billing account under which these resources will be created"
}

variable "project_id" {
  description = "The project id for the google project created"
}

variable "gcp_credentials" {
  description = "The location of the credentials for the service account that will be accessed"
}

variable "gcp_region" {
  description = "The location of the credentials for the service account that will be accessed"
}

provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.project_id
  region      = var.gcp_region
}

data "google_project" "cloudflow_project" {
  project_id = var.project_id
}

# # TODO: Figure out the correct permissions to allow for project creation...
# #
# # resource "google_project" "cloudflow" {
# #   project_id      = "cloudflow-1023"
# #   org_id          = "748067545668"
# #   billing_account = "00063B-FC0FBB-EB921F"
# #   name            = "Cloudflow Sandbox"
# # }
