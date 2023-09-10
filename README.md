## C'est image docker est optimsé pour drupal

### Docker-compose:

      version: "3"
      services:
        web:
          image: sofiene1986/apache-php:TAG
          environment:
            - SERVERNAME=localhost
            - SERVERALIAS=localhost
            - DOCUMENTROOT=
            # DOCUMENTROOT=   (vide) document root sera /var/www/html
            # DOCUMENTROOT=web   (vide) document root sera /var/www/html/web
            - USE_YARN=TRUE (Par défaut yarn ne sera pas installé)
          volumes:
            - ./html/:/var/www/html/
          ports:
            - "80:80"
            - "443:443"
#### Quelques commandes utils:
    xdebug on
    xdebug off
    xhprof on 
    xhprof off

#### Pour ajouter une tache cron, connecter au contenaire et executer les commandes suivante:
    crontab -e
    Exemple de tache cron:  
    */15 * * * * wget -q -o /dev/null http://localhost/cron/M8RKg-2INkb5ftW3-nbEeaOXfOaclufPmzKJU_43h5Z8khzXveBk0-5mAWC0mIDjF2gJNhFY5w
    Echap + :wq!      
#### Pour installer une nouvelle version de nodejs, connecter au contenaire et executer les commandes suivante:
    install-nodejs 18 (exemple)