#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(sed -n 1p /run/secrets/credentials)
WP_USER_PASS=$(sed -n 2p /run/secrets/credentials)

cd /var/www/html

# Wait (max ~60s) until MariaDB accepts TCP connections with the credentials
i=0
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${DB_PASS}" -e "SELECT 1" >/dev/null 2>&1; do
    i=$((i + 1))
    [ "$i" -ge 30 ] && echo "MariaDB not reachable" && exit 1
    sleep 2
done

# First start only: install WordPress
if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost=mariadb
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASS}" --role=author --allow-root
    chown -R www-data:www-data /var/www/html
fi

# php-fpm in the foreground (-F) as PID 1
exec php-fpm8.2 -F