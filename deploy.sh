#!/usr/bin/env bash
set -e

DOMAIN_NAME=$1

if [ -z "$DOMAIN_NAME" ]; then
  echo "Usage: ./deploy.sh <domain_name>"
fi

(aws s3 cp s3://lett-ssl-certificates/backups/"$DOMAIN_NAME".tar.gz . && tar -xzvf "$DOMAIN_NAME".tar.gz .) || true

sed "s/{{\s*domain_name\s*}}/$DOMAIN_NAME/g" docker-compose.yml.j2 > docker-compose.yml
docker-compose pull
docker-compose run --rm certbot
sudo chown -R jenkins: certbot

tar -czvf "$DOMAIN_NAME".tar.gz ./certbot
aws s3 cp "$DOMAIN_NAME".tar.gz s3://lett-ssl-certificates/backups/"$DOMAIN_NAME".tar.gz

aws s3 sync --exclude '*README*' ./certbot/conf/live/"$DOMAIN_NAME" s3://lett-ssl-certificates/"$DOMAIN_NAME"
