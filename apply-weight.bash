#!/usr/bin/env bash

set -e

contexts=NOT_SET
weight=100
source ./get-vars.bash <<< $@

for context in ${contexts//,/ }
do
  for service in ${services//,/ }
  do
    kubectl --context $context get ingress $service -o json \
    | jq -r '. | {apiVersion, kind, metadata, data, type} | del(.metadata.namespace, .metadata.creationTimestamp, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid)' \
    | jq -r ". | .metadata.annotations.\"external-dns.alpha.kubernetes.io/aws-weight\" = \"${weight}\"" \
    | kubectl --context $context apply -f -
  done
done
