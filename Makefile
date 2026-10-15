COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env -p inception
DATA    = /home/djanardh/data

all: up

up:
	@mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

logs:
	$(COMPOSE) logs -f

clean: down
	docker system prune -af

fclean: clean
	-docker volume rm mariadb_data wordpress_data
	sudo rm -rf $(DATA)

re: fclean all

.PHONY: all up down stop start logs clean fclean re