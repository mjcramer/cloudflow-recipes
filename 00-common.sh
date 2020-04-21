#!/bin/bash

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
	echo "This script can only be sourced, not executed. Please type 'source $BASH_SOURCE[0]...'"
	exit 1
fi

export PATH=$PATH:/Users/cramer/projects/lightbend/cloudflow/kubectl-cloudflow/go/bin

function forward_ports {
	kubectl port-forward my-sensor-project-http-ingress-8d7c774fd-t7chv -n my-sensor-project 3000:3000
}

function get_streamlet_pod { 
	kubectl cloudflow status $1 | awk -v s=$2 '{if ($1==s) print $2;}'
}
