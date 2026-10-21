#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
# start a temporary socket-only server
SOCK=/run/mysqld/mysqld.sock

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# First start only: the volume is empty, so initialise the database
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Temporary server, socket only (no network), just for setup
	mariadbd --user=mysql --skip-networking --socket="$SOCK" &
	TMP_PID=$!

	until mariadb-admin --socket="$SOCK" ping --silent; do
		sleep 1
	done

	mariadb --socket="$SOCK" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	mariadb-admin --socket="$SOCK" -uroot -p"${DB_ROOT_PASS}" shutdown
	wait "$TMP_PID"
fi

# exec replaces the shell, so mariadbd becomes PID 1/real server and receives signals properly
exec mariadbd --user=mysql