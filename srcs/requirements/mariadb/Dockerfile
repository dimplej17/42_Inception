# base linux OS image (debian - image name; bookworm - version)
FROM debian:bookworm

# RUN: a Dockerfile instruction
# Docker executes it while building the mariadb image, not every time the container starts
# installing mariadb server
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

# prepare the directory mariadb needs to run
RUN mkdir -p /run/mysqld \
	&& chown -R mysql:mysql /run/mysqld

# DB's default port
EXPOSE 3306

CMD ["mysql", "--user=mysql", "--console"]