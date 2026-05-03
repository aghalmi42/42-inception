FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html \
    && mkdir -p /run/php

RUN wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -O /var/www/html/adminer.php

COPY conf/adminer.conf /etc/php/8.2/fpm/pool.d/adminer.conf

EXPOSE 9001

CMD ["php-fpm8.2", "--nodaemonize"]