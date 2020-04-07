#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source $script_dir/00-common.sh

sbt cloudflowDockerImagePath
cloudflow_docker_image_path=$(cat cloudflow-docker-image-path)

gcloud auth print-access-token | kubectl cloudflow deploy $cloudflow_docker_image_path \
  --password-stdin --username oauth2accesstoken \
  --volume-mount file-ingress.source-data-mount=pv-volume
