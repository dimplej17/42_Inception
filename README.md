_This project has been created as part of the 42 curriculum by djanardh._

# Inception

## Description

Inception is a system administration project whose goal is to build a small
web infrastructure with Docker Compose inside a virtual machine. Every service
runs in its own container, built from my Dockerfiles on top of `debian:bookworm` (the penultimate stable Debian release). No ready-made images are pulled.

The stack consists of:

- **NGINX**: the only entrypoint, listening on port 443 with TLSv1.2/TLSv1.3 only.
- **WordPress + php-fpm**: the website, served to NGINX over FastCGI (port 9000).
- **MariaDB**: the database used by WordPress (port 3306, internal only).
- **Two named volumes**: one for the database, one for the WordPress files,
  both stored under `/home/djanardh/data` on the host.
- **One Docker network** connecting the containers.
- **Docker secrets** for passwords, and a `.env` file for non-secret settings.

## Instructions

Prerequisites: a Linux VM with Docker Engine, the Docker Compose plugin and `make`.

1. Create the secrets in `secrets/` (`db_password.txt`, `db_root_password.txt`,
   `credentials.txt`). See DEV_DOC.md.
2. Check `srcs/.env` (login, domain name, DB and WordPress user names).
3. Add the domain to the hosts file: `127.0.0.1 djanardh.42.fr`.
4. Run `make`.
5. Open `https://djanardh.42.fr` (accept the self-signed certificate warning).

Other commands: `make stop`, `make start`, `make down`, `make logs`,
`make fclean` (deletes containers, images and all data), `make re`.
More details: USER_DOC.md and DEV_DOC.md.

## Resources

- KodeKloud Docker Training Course for the Absolute Beginner: 
	https://kodekloud.com/courses/docker-training-course-for-the-absolute-beginner 
- Docker documentation: https://docs.docker.com

**Use of AI:** AI (Claude) was used as an auxiliary learning and review resource during development.
Ex. to explain Docker concepts such as PID 1 and daemon, help with debugging errors, and for improving structure and grammar in documentation.
All generated content was reviewed, tested, and discussed with peers, and I can explain every file.

## Project description

### Docker and the sources included

Docker packages each service with its dependencies into an isolated container.
The repository contains:

- `Makefile`: builds and manages the whole stack through docker compose.
- `srcs/docker-compose.yml`: services, network, volumes and secrets.
- `srcs/.env`: non-confidential settings (domain, user names, database name).
- `srcs/requirements/<service>/`: one Dockerfile per service, with its `conf/`
  files and `tools/` scripts (entrypoints that initialise the service, then
  `exec` it so it runs as PID 1 in the foreground).
- `secrets/`: password files, kept local and ignored by git.

### Main design choices

- Debian bookworm as the base for all three images.
- Entrypoint scripts perform first-run setup (database creation, WordPress
  installation with WP-CLI) only when the volume is empty, so restarts keep data.
- Services run in the foreground (`nginx -g "daemon off;"`, `php-fpm -F`,
  `exec mariadbd`), without `tail -f` or infinite loops.
- Only port 443 is published; MariaDB and php-fpm are reachable only on the
  internal network.
- A self-signed certificate is generated at the first NGINX start.
- `restart: unless-stopped` restarts crashed containers.

### Comparisons

**Virtual Machines vs Docker**
A VM mimics a whole machine with its own kernel, so it is heavy and slow to
start. A container shares the host kernel and isolates only processes and
filesystem, so it is lightweight and starts in seconds. VMs give stronger
isolation; containers give speed and reproducibility. Here, the VM hosts Docker
and the containers run the services.

**Secrets vs Environment Variables**
Environment variables are simple but visible through `docker inspect` and
inherited by child processes. Docker secrets are mounted as files under
`/run/secrets/` and are not shown in the container's configuration. In this
project, passwords are secrets, and non-confidential values live in `.env`.

**Docker Network vs Host Network**
A Docker bridge network gives containers their own isolated network with DNS by
service name (`mariadb`, `wordpress`), and only published ports are reachable
from outside. The host network removes this isolation and shares the host's
interfaces. It is forbidden in this project, and the user-defined network is
used for isolation and security.

**Docker Volumes vs Bind Mounts**
Bind mounts map an arbitrary host path into a container and depend on the host's
layout. Named volumes are managed by Docker, are portable, and can be
inspected with `docker volume`. This project uses named volumes configured with
the `local` driver to store data under `/home/djanardh/data`.