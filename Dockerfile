FROM mysql:8.0

COPY lumina.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306
