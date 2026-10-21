#!/bin/sh
# shebang line to tell the OS to execute the script using system shell
# A shell interprets commands such as mkdir, if, and sed

# This tells the shell to exit when a command fails (to prevent the container from appearing to start successfully when an important setup step has failed)
set -e

# -p: create parent directories if needed + don't report an error if directory already exists
mkdir -p /etc/nginx/ssl

# Self-signed certificate, generated once (if it doesn't exist)
# -f checks whether the specified path is a regular file
# CN: gives the certificate's subject information without asking interactive questions
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \ 
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=${DOMAIN_NAME}" \ 
        -addext "subjectAltName=DNS:${DOMAIN_NAME}"
fi

# Insert the real domain from .env into the config
sed "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/g" \
    /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# starting nginx web server
# -g: allows you to specify global NGINX configuration directives
# NGINX normally runs as a daemon (meaning it can detach from the process that started it).
# daemon off = nginx stays in the foreground as PID 1 (the proper way, no tail -f) ()
exec nginx -g "daemon off;"