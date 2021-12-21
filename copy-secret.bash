#!/usr/bin/env bash

secret=NOT_SET
source ./get-vars.bash <<< $@

for namespace in ${namespaces//,/ }
do
  kubectl --context live-1.cloud-platform.service.justice.gov.uk -n $namespace get secret $secret -o json | jq -r '. | {apiVersion, kind, metadata, data, type} | del(.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration", .metadata.namespace, .metadata.creationTimestamp, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid)' | kubectl --context live.cloud-platform.service.justice.gov.uk -n $namespace create -f -
done
