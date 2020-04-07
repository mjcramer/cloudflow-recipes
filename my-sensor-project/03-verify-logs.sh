#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source $script_dir/00-common.sh

kubectl logs $(get_streamlet_pod my-sensor-project valid-logger) -n my-sensor-project 

kubectl logs $(get_streamlet_pod my-sensor-project rotor-avg-logger) -f -n my-sensor-project
