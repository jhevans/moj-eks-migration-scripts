#! /bin/bash
set -e

echo "🔵🟢 Updating service values files"

source ./get-vars.bash <<< $@

# See here for reference: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster

# Steps:1,2 - done

for SERVICE in ${services//,/ }
do

  # Step 5 - Add new ingress resource in live

  cd ~/dev/$SERVICE
  branch_name=PIC-1943-clean-up
  echo "📝 Updating $(pwd)"
  git stash
  git checkout main
  git pull
  git checkout -b $branch_name
  CHART_PATH="./helm_deploy/$SERVICE"
  DEV_VALUES_PATH="./helm_deploy/values-dev.yaml"
  VALUES_PATH="./helm_deploy/$SERVICE/values.yaml"
  LIVE1_VALUES_PATH="./helm_deploy/$SERVICE/values-live1.yaml"
  LIVE_VALUES_PATH="./helm_deploy/$SERVICE/values-live.yaml"
  CIRCLECI_CONFIG_PATH="$(pwd)/.circleci/config.yml"

  echo "✏️ Updating live ingress weighting at ${LIVE_VALUES_PATH}"

  sed -i '' 's/0/100/' $LIVE_VALUES_PATH

  echo "🔥 Deleting live-1 values file at ${LIVE1_VALUES_PATH}"
  rm $LIVE1_VALUES_PATH

  echo "🔍 Linting chart..."
  helm lint $CHART_PATH --values $LIVE_VALUES_PATH --values $DEV_VALUES_PATH

  echo "🛑 Pausing for manual update of $CIRCLECI_CONFIG_PATH. Please update the circleci config and press any key to continue"
  read;

  echo "🔍 Validating circle config"
  circleci config validate
  echo "💿 Committing and pushing to git..."
  git add $LIVE_VALUES_PATH $LIVE1_VALUES_PATH $CIRCLECI_CONFIG_PATH
  git commit -m "🔥 PIC-1943: Remove live-1 deployments and send all traffic to live" --no-verify
  git push --set-upstream origin ${branch_name}  --no-verify
  git checkout main
  git branch -D ${branch_name}

  echo "✅ Done. Create a PR here https://github.com/ministryofjustice/${SERVICE}/pull/new/${branch_name}"
done
