FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/html/

RUN echo "server {\n\
    listen 8080;\n\
    root /var/www/html;\n\
    index index.html;\n\
}" > /etc/nginx/sites-available/default

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]