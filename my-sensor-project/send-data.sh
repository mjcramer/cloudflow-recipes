#!/usr/bin/env bash

for str in $(cat test-data/10-storm.json | jq -c .)
do
  echo "Using $str"
  curl -i -X POST http://localhost:3000/sensor-data -H "Content-Type: application/json" --data "$str"
done
