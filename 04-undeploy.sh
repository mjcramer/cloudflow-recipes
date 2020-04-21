#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source $script_dir/00-common.sh


kubectl cloudflow undeploy my-sensor-project 
