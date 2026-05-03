#!/bin/bash
set -e

# Verifier les variables obligatoires
for var in MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD DOMAIN_NAME \
           WP_ADMIN_USER WP_ADMIN_PASSWORD WP_ADMIN_EMAIL \
           WP_USER WP_USER_PASSWORD WP_USER_EMAIL WP_TITLE; do
    eval "val=\${$var}"
    if [ -z "$val" ]; then
        echo "Missing environment variable: $var"
        exit 1
    fi
done

WP_PATH="/var/www/html"

# Configurer php-fpm pour ecouter sur TCP 9000
sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

# Premier demarrage : WordPress pas encore installe
if [ ! -f "$WP_PATH/wp-config.php" ]; then

    # Télecharger WordPress
    wp core download --allow-root --path="$WP_PATH"

    # Attendre que MariaDB soit prete
    echo "Attente de MariaDB..."
    until bash -c "echo > /dev/tcp/mariadb/3306" 2>/dev/null; do
        sleep 2
    done
    echo "MariaDB prete."

    # Cree wp-config.php
    wp config create \
        --allow-root \
        --path="$WP_PATH" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    # Installer WordPress
    wp core install \
        --allow-root \
        --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    # Creer l'utilisateur normal
    wp user create \
        --allow-root \
        --path="$WP_PATH" \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=subscriber

    # Installer et activer le plugin Redis
    wp plugin install redis-cache --activate --allow-root --path="$WP_PATH"

    # Configurer Redis dans wp-config.php
    wp config set WP_REDIS_HOST redis --allow-root --path="$WP_PATH"
    wp config set WP_REDIS_PORT 6379 --raw --allow-root --path="$WP_PATH"

    # Attendre que Redis soit prêt
    echo "Attente de Redis..."
    until bash -c "echo > /dev/tcp/redis/6379" 2>/dev/null; do
        sleep 2
    done
    echo "Redis prêt."

    # Activer le cache Redis
    wp redis enable --allow-root --path="$WP_PATH"

    # Activer le cache Redis
    wp redis enable --allow-root --path="$WP_PATH"

    echo "WordPress installé."
fi

# Lancer php-fpm en foreground
exec php-fpm8.2 --nodaemonize