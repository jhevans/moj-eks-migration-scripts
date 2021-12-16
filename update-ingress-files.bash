#!/bin/bash

set -ex

source ./get-vars.bash <<< $@

# See here for reference: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster

# Steps:1,2 - done

for NAMESPACE in ${NAMESPACES//,/}
do

  # Step 3 - Migrate your NAMESPACE environment to live
  cd ~/dev/cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk/$NAMESPACE cloud-platform environment migrate

  # Step 4 - Authenticate - done
done
