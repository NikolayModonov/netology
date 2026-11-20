#!/bin/bash
set -e

FOLDER_ID="b1gsk9lfnqfglntfchri"
SA_NAME="diploma-sa"
BUCKET="nikolay-modonov-diploma-tf-state"
KEY_DIR="$HOME/.secrets/diploma"
KEY_FILE="$KEY_DIR/key.json"

mkdir -p "$KEY_DIR"

SA_ID=$(yc iam service-account get --name "$SA_NAME" --folder-id "$FOLDER_ID" --format json 2>/dev/null | jq -r .id 2>/dev/null || true)
if [ -z "$SA_ID" ]; then
  SA_ID=$(yc iam service-account create --name "$SA_NAME" --folder-id "$FOLDER_ID" --format json | jq -r .id)
  echo "SA $SA_NAME created: $SA_ID"
else
  echo "SA $SA_NAME exists: $SA_ID"
fi

for ROLE in editor storage.admin vpc.admin compute.admin container-registry.admin kms.keys.encrypterDecrypter load-balancer.admin iam.serviceAccounts.admin; do
  yc resource-manager folder add-access-binding --id "$FOLDER_ID" --role "$ROLE" --service-account-id "$SA_ID" 2>/dev/null || true
  echo "role $ROLE granted"
done

yc iam key create --service-account-name "$SA_NAME" --folder-id "$FOLDER_ID" --output "$KEY_FILE"
chmod 600 "$KEY_FILE"
echo "key saved: $KEY_FILE"

yc storage bucket create --name "$BUCKET" --folder-id "$FOLDER_ID" --default-storage-class standard --max-size 1073741824 2>/dev/null || echo "bucket $BUCKET already exists"
echo "done"