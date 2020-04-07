#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source $script_dir/00-common.sh

data[0]="04-moderate-breeze.json"
data[1]="10-storm.json"
data[2]="11-violent-storm.json"
data[3]="12-hurricane.json"
size=${#data[@]}

kubectl port-forward $(get_streamlet_pod my-sensor-project http-ingress) -n my-sensor-project 3000:3000 &
PORT_FORWARD_PID=$!

for i in {1..100}; do
    index=$(($RANDOM % $size))
    for str in $(cat test-data/${data[$index]} | jq -c .); do
        echo "Sending $str"
        curl -i -X POST http://localhost:3000 -H "Content-Type: application/json" --data "$str"
    done
done

kill $PORT_FORWARD_PID