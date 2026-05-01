# Inception - 42 Project

## 📚 Description

**Inception** is a system administration project from School 42 that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules, all running in separate Docker containers orchestrated with Docker Compose.

This project teaches the fundamentals of containerization, networking, volumes, security, and service orchestration while implementing a complete web stack with NGINX, WordPress, MariaDB, and additional bonus services.

> *"This project aims to broaden your knowledge of system administration by using Docker. You will virtualize several Docker images, creating them in your new personal virtual machine."*

## 🛠️ Features

### Mandatory Services

- **NGINX**: Web server with TLSv1.2 or TLSv1.3 only
- **WordPress + php-fpm**: Content Management System (without nginx)
- **MariaDB**: Database server (without nginx)
- **Volumes**: Two volumes for database and WordPress files
- **Docker Network**: Dedicated network connecting all containers
- **Auto-restart**: All containers restart automatically on crash
- **Domain Name**: `aghalmi.42.fr` pointing to local IP

### Bonus Services

- ✅ **Redis**: Cache server for WordPress optimization
- ✅ **FTP Server**: File transfer service for WordPress volume
- ✅ **Adminer**: Database management web interface
- ✅ **Static Website**: Custom static site (non-PHP)

## 📂 Project Structure

```
inception/
├── Makefile                        # Build and management commands
├── README.md                       # This file
├── DEV_DOC.md                      # Developer documentation
├── USER_DOC.md                     # User documentation
├── secrets/                        # Sensitive credentials (not in git)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                        # Environment variables
    ├── docker-compose.yml          # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile          # MariaDB container definition
        │   ├── conf/
        │   │   └── my.cnf          # MariaDB configuration
        │   └── tools/
        │       └── init-db.sh      # Database initialization script
        ├── nginx/
        │   ├── Dockerfile          # NGINX container definition
        │   └── conf/
        │       └── nginx.conf      # NGINX configuration (TLS, ports)
        ├── wordpress/
        │   ├── Dockerfile          # WordPress+PHP-FPM container
        │   └── tools/
        │       └── wp-setup.sh     # WordPress installation script
        └── bonus/
            ├── adminer/
            │   ├── Dockerfile
            │   └── conf/
            │       └── adminer.conf
            ├── ftp/
            │   ├── Dockerfile
            │   └── tools/
            │       └── ftp-setup.sh
            ├── redis/
            │   └── Dockerfile
            └── static/
                ├── Dockerfile
                └── site/
                    └── index.html
```

## 🚀 Installation & Usage

### Prerequisites

**System Requirements:**
- Docker Engine (20.10+)
- Docker Compose (1.29+)
- Linux/Unix environment or VM
- Root/sudo access for volume creation

**Network Setup:**
```bash
# Add domain to /etc/hosts
echo "127.0.0.1 aghalmi.42.fr" | sudo tee -a /etc/hosts
```

**Port Forwarding** (if using VirtualBox):
- 443 → 443 (HTTPS)
- 9001 → 9001 (Adminer)
- 8080 → 8080 (Static site)
- 21 → 21 (FTP control)
- 21100-21110 → 21100-21110 (FTP passive mode)

### 1. Clone & Setup

```bash
# Clone the repository
git clone <repository_url> inception
cd inception

# Create secrets directory
mkdir -p secrets

# Fill secrets files
echo "Wp@secure42" > secrets/db_password.txt
echo "R0ot@secure42" > secrets/db_root_password.txt
echo "Admin: webmaster / Wp@secure42" > secrets/credentials.txt
```

### 2. Configure Environment

Edit `srcs/.env` with your values:

```bash
# Domain configuration
DOMAIN_NAME=aghalmi.42.fr

# MariaDB configuration
MYSQL_DATABASE=wordpress
MYSQL_USER=aghalmi
MYSQL_PASSWORD=<from secrets/db_password.txt>
MYSQL_ROOT_PASSWORD=<from secrets/db_root_password.txt>

# WordPress Admin
WP_ADMIN_USER=webmaster
WP_ADMIN_PASSWORD=Wp@secure42
WP_ADMIN_EMAIL=admin@aghalmi.42.fr
WP_TITLE=Inception Project

# WordPress User
WP_USER=visitor
WP_USER_PASSWORD=User@42
WP_USER_EMAIL=user@aghalmi.42.fr

# FTP configuration
FTP_USER=ftpuser
FTP_PASSWORD=Ftp@secure42
```

### 3. Create Data Directories

```bash
# Create volumes directories (adjust path as needed)
mkdir -p /home/$USER/data/db
mkdir -p /home/$USER/data/wp

# Update docker-compose.yml with your path
# Replace /home/aghalmi/data with your actual path
```

### 4. Build & Run

```bash
# Build and start all services
make

# Check services are running
make ps

# View logs
make logs

# Follow logs in real-time
make logs-f
```

### 5. Access Services

| Service | URL | Description |
|---------|-----|-------------|
| WordPress | https://aghalmi.42.fr | Main website |
| WordPress Admin | https://aghalmi.42.fr/wp-admin | Admin panel |
| Adminer | https://aghalmi.42.fr:9001/adminer.php | Database management |
| Static Site | http://aghalmi.42.fr:8080 | Custom static page |
| FTP | ftp://127.0.0.1:21 | File transfer |

### 6. Stop & Clean

```bash
# Stop containers (keep data)
make down

# Stop and remove everything
make fclean

# Rebuild everything from scratch
make re
```

## ⚙️ Service Details

### NGINX

**Port:** 443 (HTTPS)  
**Configuration:**
- TLSv1.2 and TLSv1.3 only
- Self-signed SSL certificate
- Reverse proxy to WordPress (port 9000)
- Serves static files
- Additional ports for bonus services (9001, 8080)

**Key Features:**
```nginx
# TLS configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_certificate /etc/nginx/ssl/nginx.crt;
ssl_certificate_key /etc/nginx/ssl/nginx.key;

# WordPress proxy
location ~ \.php$ {
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
}
```

### MariaDB

**Port:** 3306 (internal only)  
**Volume:** `/var/lib/mysql` → `/home/$USER/data/db`

**Features:**
- Database created on first run
- User with full privileges on WordPress database
- Root password configured from environment
- Data persisted in volume
- Health checks via mysqladmin ping

**Initialization:**
```bash
# Creates database and users
CREATE DATABASE wordpress;
CREATE USER 'aghalmi'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'aghalmi'@'%';
```

### WordPress + PHP-FPM

**Port:** 9000 (PHP-FPM, internal)  
**Volume:** `/var/www/html` → `/home/$USER/data/wp`

**Features:**
- WordPress CLI (WP-CLI) for automation
- Automatic installation on first run
- Admin and regular user creation
- Redis cache integration (bonus)
- PHP-FPM listens on TCP (not socket)

**Installation Process:**
1. Download WordPress core
2. Create `wp-config.php`
3. Install WordPress with credentials
4. Create additional user
5. Configure Redis cache

### Redis (Bonus)

**Port:** 6379 (internal only)

**Features:**
- Object caching for WordPress
- Improves performance significantly
- Configured via WordPress Redis Cache plugin
- Connects to `redis:6379`

**Integration:**
```php
// In wp-config.php
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
```

### FTP Server (Bonus)

**Ports:** 21 (control), 21100-21110 (passive)

**Features:**
- vsftpd server
- Access to WordPress volume
- User created from environment
- Chroot jail for security
- Passive mode for VM compatibility

**Configuration:**
```conf
local_enable=YES
write_enable=YES
chroot_local_user=YES
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
```

### Adminer (Bonus)

**Port:** 9001 (via NGINX)  
**URL:** https://aghalmi.42.fr:9001/adminer.php

**Features:**
- Lightweight database management
- Single PHP file
- Connects to MariaDB service
- User-friendly interface

**Access:**
- Server: `mariadb`
- Username: `aghalmi`
- Password: from `.env`
- Database: `wordpress`

### Static Site (Bonus)

**Port:** 8080 (via NGINX)  
**URL:** http://aghalmi.42.fr:8080

**Features:**
- Simple HTML/CSS/JS site
- No PHP processing
- Custom landing page
- Minimal NGINX configuration

## 🌐 Docker Network & Volumes

### Network Architecture

```
┌─────────────────────────────────────────────────┐
│                  inception (bridge)              │
│                                                  │
│  ┌────────┐  ┌──────────┐  ┌─────────┐         │
│  │ NGINX  │─→│WordPress │─→│ MariaDB │         │
│  │  :443  │  │  :9000   │  │  :3306  │         │
│  └────────┘  └──────────┘  └─────────┘         │
│       ↓           ↓                              │
│  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │Adminer │  │ Redis  │  │  FTP   │            │
│  │        │  │ :6379  │  │  :21   │            │
│  └────────┘  └────────┘  └────────┘            │
│       ↓                                          │
│  ┌────────┐                                     │
│  │ Static │                                     │
│  └────────┘                                     │
└─────────────────────────────────────────────────┘
```

### Volumes

**db_data:**
- **Container path:** `/var/lib/mysql`
- **Host path:** `/home/$USER/data/db`
- **Purpose:** MariaDB database files
- **Persistence:** Survives container restart/recreation

**wp_data:**
- **Container path:** `/var/www/html`
- **Host path:** `/home/$USER/data/wp`
- **Purpose:** WordPress files (core, themes, plugins, uploads)
- **Shared by:** WordPress, NGINX, FTP
- **Persistence:** Survives container restart/recreation

## 🔒 Security Considerations

### SSL/TLS

- **Protocol:** TLSv1.2 and TLSv1.3 only (TLSv1.0 and TLSv1.1 disabled)
- **Certificate:** Self-signed (for local development)
- **Generation:**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=aghalmi.42.fr"
```

### Credentials Management

**Secrets Directory:**
- Never committed to Git (in `.gitignore`)
- Stored locally only
- Mounted as volumes or passed as environment variables

**Environment Variables:**
- Sensitive data in `.env` file
- Not hardcoded in Dockerfiles
- Passed to containers at runtime

### Container Isolation

- Each service in separate container
- Minimal base images (Alpine Linux)
- Non-root users where possible
- Limited network exposure

### Database Security

- Root password required
- User with limited privileges
- No external port exposure
- Connection only from docker network

## 📝 Makefile Commands

```bash
make          # Build and start all services
make build    # Build all images without cache
make up       # Start services (after build)
make down     # Stop services (keep data)
make ps       # Show running containers
make logs     # View all logs
make logs-f   # Follow logs in real-time
make clean    # Stop and remove containers
make fclean   # Full cleanup (removes volumes)
make re       # Rebuild everything from scratch
```

## 🐛 Troubleshooting

### WordPress Installation Issues

**Problem:** WordPress shows setup screen instead of site  
**Solution:**
```bash
# Check if wp-config.php exists
docker exec wordpress ls -la /var/www/html/wp-config.php

# Check database connection
docker exec wordpress wp db check --allow-root --path=/var/www/html

# Reinstall if needed
make down
rm -rf /home/$USER/data/wp/*
make up
```

### MariaDB Connection Failed

**Problem:** WordPress can't connect to database  
**Solution:**
```bash
# Check MariaDB is running
docker exec mariadb mysqladmin ping

# Verify credentials in .env match init-db.sh
cat srcs/.env | grep MYSQL_

# Check database exists
docker exec -it mariadb mysql -u root -p
> SHOW DATABASES;
> USE wordpress;
```

### NGINX 502 Bad Gateway

**Problem:** NGINX can't reach WordPress  
**Solution:**
```bash
# Check WordPress container is running
docker ps | grep wordpress

# Verify PHP-FPM is listening
docker exec wordpress netstat -tlnp | grep 9000

# Check NGINX logs
docker logs nginx
```

### SSL Certificate Errors

**Problem:** Browser shows SSL warning  
**Solution:**
- Self-signed certificates always show warnings
- Click "Advanced" → "Proceed anyway"
- For production, use Let's Encrypt or proper CA

### Permission Denied on Volumes

**Problem:** Can't write to mounted volumes  
**Solution:**
```bash
# Check volume ownership
ls -la /home/$USER/data/wp
ls -la /home/$USER/data/db

# Fix permissions if needed
sudo chown -R $USER:$USER /home/$USER/data
chmod -R 755 /home/$USER/data
```

### Redis Not Connecting

**Problem:** WordPress can't connect to Redis  
**Solution:**
```bash
# Check Redis is running
docker exec redis redis-cli ping
# Should return: PONG

# Verify WordPress Redis settings
docker exec wordpress wp config get WP_REDIS_HOST --allow-root

# Re-enable Redis cache
docker exec wordpress wp redis enable --allow-root
```

## 🧪 Testing

### Service Availability Tests

```bash
# Test NGINX
curl -k https://aghalmi.42.fr

# Test WordPress
curl -k https://aghalmi.42.fr/wp-admin

# Test Adminer
curl -k https://aghalmi.42.fr:9001/adminer.php

# Test Static Site
curl http://aghalmi.42.fr:8080

# Test MariaDB (from within network)
docker exec wordpress nc -zv mariadb 3306

# Test Redis (from within network)
docker exec wordpress nc -zv redis 6379
```

### Volume Persistence Test

```bash
# Create test file in WordPress
docker exec wordpress touch /var/www/html/test.txt

# Stop containers
make down

# Start containers
make up

# Check file still exists
docker exec wordpress ls /var/www/html/test.txt
```

### FTP Connection Test

```bash
# Using command-line FTP client
ftp 127.0.0.1 21
# Username: ftpuser
# Password: from .env

# Using FileZilla or similar
# Host: 127.0.0.1
# Port: 21
# Protocol: FTP
# Mode: Passive
```

## 💡 Best Practices

### Dockerfile Guidelines

✅ **Do:**
- Use specific base image versions (e.g., `alpine:3.18`)
- Install only necessary packages
- Clean package cache after installation
- Use multi-stage builds when applicable
- Group RUN commands to reduce layers
- Use COPY instead of ADD unless extracting archives
- Set working directory with WORKDIR

❌ **Don't:**
- Use `latest` tags in production
- Install unnecessary packages
- Leave package cache
- Run services as root
- Store secrets in images
- Use excessive layers

### docker-compose.yml Best Practices

✅ **Do:**
- Use version-specific service definitions
- Define explicit networks
- Use named volumes
- Set restart policies
- Define health checks
- Use env_file for environment variables
- Specify depends_on for service order

❌ **Don't:**
- Hardcode sensitive data
- Use default bridge network
- Expose unnecessary ports
- Mix development and production configs

### Security Best Practices

✅ **Do:**
- Use strong passwords
- Keep secrets in separate files
- Update base images regularly
- Limit container privileges
- Use non-root users
- Enable only necessary ports
- Implement health checks

❌ **Don't:**
- Commit secrets to Git
- Use default passwords
- Run as root unnecessarily
- Expose all ports publicly
- Disable security features

## 📊 Project Requirements Checklist

### Mandatory

- [x] Each service runs in dedicated container
- [x] Containers built from Alpine or Debian penultimate stable
- [x] Dockerfiles written by hand (one per service)
- [x] NGINX with TLSv1.2/1.3 only
- [x] WordPress + php-fpm (without nginx)
- [x] MariaDB (without nginx)
- [x] Volumes for database and WordPress files
- [x] Docker network connecting containers
- [x] Containers restart on crash
- [x] Domain name configured (aghalmi.42.fr)
- [x] No passwords in Dockerfiles
- [x] Environment variables used
- [x] .env file for sensitive data
- [x] Volumes mount to /home/$USER/data

### Bonus

- [x] Redis cache for WordPress
- [x] FTP server pointing to WordPress volume
- [x] Adminer (database management)
- [x] Static website (non-PHP)
- [x] Proper service isolation
- [x] Docker network for all services
- [x] Bonus services in `requirements/bonus/`

## 🎓 Learning Outcomes

- **Docker Fundamentals**: Images, containers, volumes, networks
- **Service Orchestration**: Docker Compose multi-container apps
- **Web Stack**: NGINX, PHP-FPM, MariaDB interaction
- **System Administration**: Service configuration and management
- **Security**: SSL/TLS, credential management, isolation
- **Automation**: Scripts for initialization and setup
- **Networking**: Inter-container communication, port mapping
- **Data Persistence**: Volume management and backup strategies

## 📚 Resources

### Official Documentation

- [Docker Documentation](https://docs.docker.com/) - Complete Docker reference
- [Docker Compose](https://docs.docker.com/compose/) - Multi-container orchestration
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) - Official guidelines
- [NGINX Documentation](https://nginx.org/en/docs/) - Web server configuration
- [MariaDB Documentation](https://mariadb.com/kb/en/) - Database server
- [WordPress Codex](https://codex.wordpress.org/) - WordPress documentation
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/) - WordPress CLI tool

### Tutorials & Guides

- [Docker Tutorial for Beginners](https://docker-curriculum.com/) - Interactive guide
- [NGINX Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html) - Getting started
- [WordPress Docker Setup](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose) - Complete guide
- [SSL/TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS) - Security configuration

### Tools & Utilities

- [Docker Desktop](https://www.docker.com/products/docker-desktop) - GUI for Docker
- [Portainer](https://www.portainer.io/) - Container management UI
- [ctop](https://github.com/bcicen/ctop) - Container metrics monitoring
- [dive](https://github.com/wagoodman/dive) - Docker image layer explorer

## ⚠️ Important Notes

### VM Configuration

If using a virtual machine (VirtualBox):
1. Configure port forwarding for all required ports
2. Ensure sufficient resources (RAM, CPU, Disk)
3. Enable nested virtualization if available
4. Set network adapter to Bridged or NAT

### Data Backup

**Before `make fclean`:**
```bash
# Backup WordPress
sudo tar -czf wp_backup.tar.gz /home/$USER/data/wp

# Backup MariaDB
docker exec mariadb mysqldump -u root -p wordpress > wp_backup.sql
```

### 42 School Specifics

- Domain must be `login.42.fr`
- Volumes must be in `/home/login/data`
- All containers must restart automatically
- No `network: host` or `links:` allowed
- No infinite loops in entrypoints (use exec)

---

**Project completed as part of the 42 School curriculum by aghalmi** 🚀

*Good luck with your deployment!*****
