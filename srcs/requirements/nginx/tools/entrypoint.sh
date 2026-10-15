#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl

# Self-signed certificate, generated once
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

# Insert the real domain from .env into the config
sed "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/g" \
    /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# daemon off = nginx stays in the foreground as PID 1 (the proper way, no tail -f)
exec nginx -g "daemon off;"