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
      
Pour ajouter une tache cron, connecter au contenaire et executer les commandes suivante:
1) crontab -e
2) exemple de tache cron */15 * * * * wget -q -o /dev/null http://localhost/cron/M8RKg-2INkb5ftW3-nbEeaOXfOaclufPmzKJU_43h5Z8khzXveBk0-5mAWC0mIDjF2gJNhFY5w
3) Echap + :wq!      
