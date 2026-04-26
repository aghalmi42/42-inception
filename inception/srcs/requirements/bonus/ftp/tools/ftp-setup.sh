#!/bin/bash
set -e

# Créer l'utilisateur FTP
useradd -m -d /var/www/html "$FTP_USER" 2>/dev/null || true
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Donner accès au volume WordPress
chown -R "$FTP_USER":www-data /var/www/html
chmod -R 755 /var/www/html

# Config vsftpd
cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=127.0.0.1
local_root=/var/www/html
EOF

mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf