#!/usr/bin/env bash

set -e

contexts=NOT_SET
replicas=1
source ./get-vars.bash <<< $@

for context in ${contexts//,/ }
do
  for service in ${services//,/ }
  do
    kubectl --context $context scale deployment $service --replicas $replicas
  done
done
