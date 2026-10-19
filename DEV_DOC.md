# Developer documentation

## Prerequisites

- A Linux virtual machine with `make`, Docker Engine and the Docker Compose plugin.
- Your user in the `docker` group (`sudo usermod -aG docker $USER`, then log in again).
- A hosts entry for the domain: `127.0.0.1 djanardh.42.fr` in `/etc/hosts`.

## Setting up from scratch

1. Clone the repository.
2. Create the secrets (they are not in git). Use alphanumeric passwords:
```bash
   mkdir -p secrets
   printf '%s' '<db password>'       > secrets/db_password.txt
   printf '%s' '<db root password>'  > secrets/db_root_password.txt
   printf '%s\n%s\n' '<wp admin password>' '<wp user password>' > secrets/credentials.txt
```
3. Edit `srcs/.env`:
   - `LOGIN` must equal your system username.
   - `DOMAIN_NAME`, `MYSQL_DATABASE`, `MYSQL_USER`, `WP_*` values.
   - The WordPress admin name must not contain "admin" or "administrator".

## Build and launch

`make` - creates `/home/<login>/data/{mariadb,wordpress}`, then `docker compose up -d --build` 
`make stop` / `make start` - stops / starts the existing containers 
`make down` - removes containers and the network (volumes' data stays) 
`make logs` - follows the logs of all services 
`make clean` - `down` + prune unused Docker objects 
`make fclean` - `clean` + removes the volumes and deletes `/home/<login>/data` 
`make re` - `fclean` then `all` 

## Useful commands

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env -p inception ps
docker logs <mariadb|wordpress|nginx>
docker exec -it wordpress sh               # shell inside a container
docker exec -it mariadb mariadb -u root -p # database console
docker images                              # locally built images (tag 1.0)
docker volume ls
docker volume inspect mariadb_data         # see "device": /home/<login>/data/mariadb
docker network ls
```

## Data storage and persistence

- Two named volumes, defined in `srcs/docker-compose.yml`:
  - `mariadb_data` mounted at `/var/lib/mysql` in the mariadb container
  - `wordpress_data` mounted at `/var/www/html` in the wordpress container
    (read-only in nginx)
- Both use the `local` driver with `type: none` and `o: bind`, so their data
  is physically stored on the host in `/home/<login>/data/mariadb` and
  `/home/<login>/data/wordpress`.
- Data survives `make stop`, `make down`, container rebuilds and VM reboots.
  It is erased only by `make fclean`.
- Initialisation scripts run only when the data directory is empty
  (MariaDB: database missing; WordPress: no `wp-config.php`), so restarting
  never overwrites existing data.
- Containers use `restart: unless-stopped`, so Docker brings them back after a
  crash or a reboot.
