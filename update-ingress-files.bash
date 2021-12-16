#! /bin/bash
set -e

echo "🔵🟢 Updating service values files"

source ./get-vars.bash <<< $@

# See here for reference: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster

# Steps:1,2 - done

for SERVICE in ${services//,/}
do

  # Step 5 - Add new ingress resource in live

  cd ~/dev/$SERVICE
  branch_name=PIC-1943-add-ingress
  echo "📝 Updating $(pwd)"
  git stash
  git checkout main
  git pull
  CHART_PATH="./helm_deploy/$SERVICE"
  DEV_VALUES_PATH="./helm_deploy/values-dev.yaml"
  LIVE1_VALUES_PATH="./helm_deploy/$SERVICE/values.yaml"
  LIVE_VALUES_PATH="./helm_deploy/$SERVICE/values-live.yaml"
  # If a new values file does not exist, create it
  if ! test -f LIVE_VALUES_PATH; then
    git checkout -b PIC-1943-add-ingress

    INGRESS_TEMPLATE_PATH=${CHART_PATH}/templates/ingress.yaml
    UPDATED_INGRESS_TEMPLATE_PATH=${CHART_PATH}/templates/ingress.yaml.temp
    if test -f $INGRESS_TEMPLATE_PATH; then
      echo "📝 Updating ${INGRESS_TEMPLATE_PATH} with .Values.ingress.contextColour"
      sed 's/-blue/-{{ .Values.ingress.contextColour }}/' $INGRESS_TEMPLATE_PATH > $UPDATED_INGRESS_TEMPLATE_PATH
      rm $INGRESS_TEMPLATE_PATH
      mv $UPDATED_INGRESS_TEMPLATE_PATH $INGRESS_TEMPLATE_PATH
    fi

    # If an old values file exists then copy it, otherwise create an empty one
    NEW_ANNOTATIONS=$(sed s/NAMESPACE/$NAMESPACE/ ~/dev/eks-migration/ingress-annotations | sed s/SERVICE/$SERVICE/)
    if test -f LIVE1_VALUES_PATH; then
    echo "✏️ Existing values file at ${LIVE1_VALUES_PATH} - adding new values"
      cp "./helm_deploy/$SERVICE/values.yaml" $LIVE_VALUES_PATH | \
      sed '/^ingress:.*/a   contextColour: green' | \
      sed '/^ingress:.*/a   annotations:' | \
      sed '/^annotations:.*/a     external-dns.alpha.kubernetes.io/aws-weight: "0"' > $LIVE_VALUES_PATH
    else
      echo "✨ No file at ${LIVE1_VALUES_PATH} - creating new values files"
      echo "ingress:" > $LIVE1_VALUES_PATH
      echo "  contextColour: blue" >> $LIVE1_VALUES_PATH
      echo "  annotations:" >> $LIVE1_VALUES_PATH
      echo '    external-dns.alpha.kubernetes.io/aws-weight: "100"' >> $LIVE1_VALUES_PATH

      echo "ingress:" > $LIVE_VALUES_PATH
      echo "  contextColour: green" >> $LIVE_VALUES_PATH
      echo "  annotations:" >> $LIVE_VALUES_PATH
      echo '    external-dns.alpha.kubernetes.io/aws-weight: "0"' >> $LIVE_VALUES_PATH
    fi

    echo "🔍 Linting chart..."
    helm lint $CHART_PATH --values $LIVE_VALUES_PATH --values $DEV_VALUES_PATH
    echo "💿 Committing and pushing to git..."
    git add $LIVE_VALUES_PATH $LIVE1_VALUES_PATH $INGRESS_TEMPLATE_PATH
    git commit -m "✨ PIC-1943: Update helm and values files for new live cluster" --no-verify
    git push --set-upstream origin ${branch_name}  --no-verify
    git checkout main
    git branch -D ${branch_name}
  fi
  echo "✅ Done. Create a PR here https://github.com/ministryofjustice/${SERVICE}/pull/new/${branch_name}"
done
