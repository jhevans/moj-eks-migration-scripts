#!/bin/bash

set -e

echo "🧳 Migrating namespaces from live-1 to live"

source ./get-vars.bash <<< $@

# See here for reference: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster

# Steps:1,2 - done

for namespace in ${namespaces//,/}
do

  # Step 3 - Migrate your namespace environment to live

  echo "🚚 Migrating ${namespace}..."
  branch_name=PIC-1943-${namespace}
  cd ~/dev/cloud-platform-environments/namespaces/live-1.cloud-platform.service.justice.gov.uk/${namespace}
  git stash
  git checkout main
  git pull
  git checkout -b ${branch_name}
  cloud-platform environment migrate
  echo "💿 Committing and pushing to git..."
  cd ~/dev/cloud-platform-environments/
  git add .
  git commit -m "🚚 PIC-1943: Migrate ${namespace} to live"
  git push --set-upstream origin ${branch_name}
  git checkout main
  git branch -D ${branch_name}

  echo "✅ Finished migrating ${namespace}..."
  echo "🧑‍💻 Create a pull request here: https://github.com/ministryofjustice/cloud-platform-environments/pull/new/${branch_name}"

  # Step 4 - Authenticate - done
done
