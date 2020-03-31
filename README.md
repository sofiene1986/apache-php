## C'est image docker est optimsé pour drupal

### Docker-compose:

version: "3"

services:

  web:
  
    build: apache-php
    environment:
      - SERVERNAME=localhost
      - SERVERALIAS=localhost
      - DOCUMENTROOT=
      # DOCUMENTROOT=   (vide) document root sera /var/www/html
      # DOCUMENTROOT=web   (vide) document root sera /var/www/html/web
    volumes:
      - ./html/:/var/www/html/
    ports:
      - "80:80"
