FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/mysql/mariadb.conf.d/50-server.cnf

RUN sed -i 's/bind-address.*=.*127.0.0.1/bind-address = 0.0.0.0/' \
    /etc/mysql/mariadb.conf.d/50-server.cnf 2>/dev/null || true

COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY tools/init-db.sh /usr/local/bin/init-db.sh

RUN chmod +x /usr/local/bin/init-db.sh \
    && chown -R mysql:mysql /var/lib/mysql \
    && mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && rm -rf /var/lib/mysql/*

EXPOSE 3306

ENTRYPOINT ["init-db.sh"]