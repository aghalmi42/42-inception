# User Documentation

## Services

| Service | URL |
|---|---|
| WordPress | https://aghalmi.42.fr |
| Adminer | https://aghalmi.42.fr:9001/adminer.php |
| Static site | http://aghalmi.42.fr:8080 |
| FTP | ftp://127.0.0.1:21 |

## Start / Stop

```bash
# Start all services
make

# Stop without deleting data
make down

# Stop and delete everything
make fclean
```

## Access WordPress admin

Go to `https://aghalmi.42.fr/wp-admin` and login with :

- Username : `webmaster`
- Password : see `secrets/credentials.txt`

## Access Adminer

Go to `https://aghalmi.42.fr:9001/adminer.php` and login with :

- Server : `mariadb`
- Username : `aghalmi`
- Password : see `secrets/db_password.txt`
- Database : `wordpress`

## Credentials

All credentials are stored in the `secrets/` folder at the root of the repository.

## Check services are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

All containers should show `Up`.