
COMPOSE_FILE = srcs/docker-compose.yml

all:
	@mkdir -p /home/aghalmi/data/db
	@mkdir -p /home/aghalmi/data/wp
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@docker compose -f $(COMPOSE_FILE) down -v

fclean:
	@docker compose -f $(COMPOSE_FILE) down -v
	@sudo rm -rf /home/aghalmi/data/db/*
	@sudo rm -rf /home/aghalmi/data/wp/*
	@docker system prune -af

re: fclean all

.PHONY: all down clean fclean re