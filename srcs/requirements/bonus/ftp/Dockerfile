FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY tools/ftp-setup.sh /usr/local/bin/ftp-setup.sh
RUN chmod +x /usr/local/bin/ftp-setup.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["ftp-setup.sh"]