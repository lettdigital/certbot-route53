# certbot-route53

This project creates certificates for both root and star certificate of a specific domain. For example, when DOMAIN_NAME
is set to `example.com`, the generated certificate called `example.com` will be valid for both the DOMAIN_NAME and
`*.example.com`.

## How to use

- run `deploy.sh <domain_name>`.
