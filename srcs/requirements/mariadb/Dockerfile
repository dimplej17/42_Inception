# base linux OS image (debian - image name; bookworm - version)
FROM debian:bookworm

# RUN: a Dockerfile instruction
# Docker executes it while building the mariadb image, not every time the container starts
# installing mariadb server
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

# DB's default port
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]