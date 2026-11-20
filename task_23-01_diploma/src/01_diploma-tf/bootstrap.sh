#!/bin/bash
set -euo pipefail

source "$HOME/.secrets/netology/diploma/env.sh"

SA_NAME="diploma-sa"
BUCKET="$YC_STATE_BUCKET"
KEY_FILE="$HOME/.secrets/netology/diploma/key.json"

SA_ID=$(yc iam service-account get --name "$SA_NAME" --folder-id "$YC_FOLDER_ID" --format json 2>/dev/null | jq -r .id 2>/dev/null || true)
if [ -z "$SA_ID" ]; then
  SA_ID=$(yc iam service-account create --name "$SA_NAME" --folder-id "$YC_FOLDER_ID" --format json | jq -r .id)
  echo "SA $SA_NAME created: $SA_ID"
else
  echo "SA $SA_NAME exists: $SA_ID"
fi

for ROLE in editor storage.admin vpc.admin compute.admin container-registry.admin kms.keys.encrypterDecrypter load-balancer.admin iam.serviceAccounts.admin; do
  yc resource-manager folder add-access-binding --id "$YC_FOLDER_ID" --role "$ROLE" --service-account-id "$SA_ID" 2>/dev/null || true
  echo "role $ROLE granted"
done

yc iam key create --service-account-name "$SA_NAME" --folder-id "$YC_FOLDER_ID" --output "$KEY_FILE"
chmod 600 "$KEY_FILE"
echo "key saved: $KEY_FILE"

yc storage bucket create --name "$BUCKET" --folder-id "$YC_FOLDER_ID" --default-storage-class standard --max-size 1073741824 2>/dev/null || echo "bucket $BUCKET already exists"
echo "done"