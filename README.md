*This project has been created as part of the 42 curriculum by aghalmi.*

## Description

Inception is a system administration project that uses Docker to set up a small
infrastructure composed of multiple services. Each service runs in a dedicated
container built from scratch using Debian Bookworm.

### Services

- **NGINX** — reverse proxy with TLSv1.2/TLSv1.3, single entrypoint on port 443
- **WordPress** — CMS with php-fpm, no nginx
- **MariaDB** — database server

### Design choices

| Topic | Choice |
|---|---|
| VM vs Docker | Docker uses less resources, faster to deploy |
| Secrets vs Env vars | Secrets for passwords, env vars for config |
| Docker network vs Host | Docker network isolates containers |
| Named volumes vs Bind mounts | Named volumes for persistence, bind mounts forbidden |

## Instructions

```bash
# Start
make

# Stop
make down

# Full clean
make fclean

# Rebuild
make re
```

## Resources

- [Docker documentation](https://docs.docker.com)
- [WordPress CLI](https://wp-cli.org)
- [NGINX docs](https://nginx.org/en/docs)
- [MariaDB docs](https://mariadb.com/kb/en)

### AI usage

AI was used to understand concepts (php-fpm, FastCGI, TLS) and debug
configuration issues. All generated content was reviewed and tested manually.