#!/usr/bin/env bash
set -e

DOMAIN_NAME=$1
CERTBOT_EMAIL=$2
TARGET_BUCKET=$3

if [ -z "$DOMAIN_NAME" ] || [ -z "$CERTBOT_EMAIL" ] || [ -z "$TARGET_BUCKET" ]; then
  echo "Usage: ./deploy.sh <domain_name> <certbot_email> <target_bucket>"
  exit 1
fi

(aws s3 cp s3://"$TARGET_BUCKET"/backups/"$DOMAIN_NAME".tar.gz . && tar -xzvf "$DOMAIN_NAME".tar.gz .) || true

sed "s/{{\s*domain_name\s*}}/$DOMAIN_NAME/g" docker-compose.yml.j2 |
  sed "s/{{\s*email\s*}}/$CERTBOT_EMAIL/g" > docker-compose.yml

docker-compose pull
docker-compose run --rm certbot
sudo chown -R "$(id -un)": certbot

tar -czvf "$DOMAIN_NAME".tar.gz ./certbot
aws s3 cp "$DOMAIN_NAME".tar.gz s3://"$TARGET_BUCKET"/backups/"$DOMAIN_NAME".tar.gz

aws s3 sync --exclude '*README*' ./certbot/conf/live/"$DOMAIN_NAME" s3://"$TARGET_BUCKET"/"$DOMAIN_NAME"
