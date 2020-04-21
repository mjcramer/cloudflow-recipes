#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

if [ -e $script_dir/.env ]; then
    source $script_dir/.env
fi

gcloud projects create $TF_VAR_project_name \
  --set-as-default

gcloud beta billing projects link $TF_VAR_project_name \
  --billing-account $TF_VAR_billing_account
