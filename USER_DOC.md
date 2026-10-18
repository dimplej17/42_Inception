# User documentation

## Services provided

1. NGINX: web entrypoint (HTTPS, port 443) 
2. WordPress (php-fpm): The website and its administration panel 
3. MariaDB: Database storing the site's content and users 

## Start and stop

Run these from the root of the repository:

`make` - Build and start everything 
`make stop` - Stop (keep containers and data) 
`make start` - Start again after a stop 
`make down` - Remove containers (data is kept) 
`make fclean` (**destructive**) - Remove everything including data 

## Access the website and the administration panel

1. Make sure `127.0.0.1 djanardh.42.fr` is in `/etc/hosts` of the machine
   whose browser you use.
2. Website: https://djanardh.42.fr
3. Administration panel: https://djanardh.42.fr/wp-admin

The certificate is self-signed, so the browser shows a warning the first time.
Choose "Advanced", then "Accept the Risk and Continue".

## Credentials

- Passwords are stored in the `secrets/` folder (not in git):
  - `db_root_password.txt`: MariaDB root password
  - `db_password.txt`: password of the WordPress database user
  - `credentials.txt`: line 1 is the WordPress administrator password,
    line 2 is the second WordPress user's password
- Usernames and the domain name are in `srcs/.env`
  (administrator: `wpmanager`, second user: `wpauthor`).
- To change a WordPress password, use the profile page in the admin panel.
  Editing the files in `secrets/` after the first start does **not** change
  existing accounts, because WordPress and MariaDB are initialised only once.

## Check that the services are running

```bash
docker ps                                  # nginx, wordpress, mariadb should be "Up"
curl -k -I https://djanardh.42.fr          # should answer with an HTTP status line
docker logs nginx                          # also: docker logs wordpress / mariadb
```
If a container is missing or restarting, check its logs with `docker logs <name>`.