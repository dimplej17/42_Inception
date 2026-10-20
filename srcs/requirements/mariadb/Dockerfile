# base linux OS image (debian - image name; bookworm - version)
FROM debian:bookworm

# RUN: a Dockerfile instruction to run a command
# Docker executes it while building the mariadb image, not every time the container starts
# installing mariadb server (&&: Runs the next command only if the previous command succeeds)
# -y: answer yes to prompts during installation
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server \
	&& rm -rf /var/lib/apt/lists/*
# Removes downloaded package-list files after installation - helps reduce the final image size
# rm removes files, -r allows recursive removal, -f suppresses many prompts and errors for missing files

# copies files from the Docker build context into the image
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

# DB's default port (container is intended to listen on port 443, not pusblishing port to host machine! mapping happens in the yml file)
EXPOSE 3306

# defines the main executable that runs when a container starts
ENTRYPOINT ["/usr/local/bin/init.sh"]