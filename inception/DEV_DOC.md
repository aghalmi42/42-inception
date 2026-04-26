# Developer Documentation

## Prerequisites

- Docker and Docker Compose installed
- VirtualBox with port forwarding configured :
  - 443  → 443
  - 9001 → 9001
  - 8080 → 8080
  - 21   → 21
- Entry in `/etc/hosts` : `127.0.0.1 aghalmi.42.fr`

## Project structure

inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
├── .env
├── docker-compose.yml
└── requirements/
├── mariadb/
├── nginx/
├── wordpress/
└── bonus/
├── adminer/
├── redis/
├── static/
└── ftp/

## Setup from scratch

```bash
# 1. Fill secrets
echo "Wp@secure42"   > secrets/db_password.txt
echo "R0ot@secure42" > secrets/db_root_password.txt

# 2. Check .env is filled
cat srcs/.env

# 3. Create data directories
mkdir -p /home/aghalmi/data/db
mkdir -p /home/aghalmi/data/wp

# 4. Build and start
make
```

## Useful commands

```bash
# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Enter a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# Check volumes
ls /home/aghalmi/data/db
ls /home/aghalmi/data/wp
```

## Data persistence

- MariaDB data : `/home/aghalmi/data/db`
- WordPress files : `/home/aghalmi/data/wp`

Data survives `make down` but is deleted with `make fclean`.