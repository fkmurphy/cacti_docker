FROM alpine:3.10

RUN apk update && apk upgrade && apk add --update --no-cache  \
	apache2 php7 php7-apache2 php7-session php7-mysqli \ 
	php7-pdo_mysql php7-xml php7-json php7-ctype php7-gd \ 
	php7-gmp php7-mbstring php7-simplexml php7-sockets php7-posix php7-ldap \
	# perl
	perl \
	# fonts para gráficos
	ttf-dejavu \
	# ttf-liberation
	#Opcionales
    php7-gettext php7-snmp\
	# cron y conexión mysql
	dcron curl wget mysql-client \
	# herramientas para cacti
	rrdtool net-snmp net-snmp-tools \
	# gestion de servicios
	openrc

#Directorio de cacti
RUN mkdir /var/www/cacti
WORKDIR /var/www/cacti

# copia de cacti
COPY ./data .

RUN chown -R apache.apache rra; chown -R apache.apache log
RUN chmod -R 777 rra; chmod -R 777 log
 
# copia de configuraciones
COPY ./configs/cacti_config.php include/config.php
COPY ./configs/httpd.conf /etc/apache2/httpd.conf
COPY ./configs/php.ini /etc/php7/php.ini
COPY ./configs/snmpd.conf /etc/snmp/snmpd.conf

# variables de ambiente
ENV \
    DB_NAME=cacti \
    DB_USER=cactiuser \
    DB_PASS=cactipassword \
    DB_HOST=localhost \
    DB_PORT=3306 \
    DOMAIN=127.0.0.1 \
    SNMP_COMMUNITY=public \
    REMOTE_POLLER=0 \
    TZ=UTC

# escuchar en puertos
EXPOSE 80 443 161

# copiar script de inicio y ejecutar
COPY inicio.sh /inicio.sh
CMD ["/inicio.sh"]
#ENTRYPOINT ["/usr/sbin/httpd"]
#CMD ["-D", "FOREGROUND"]
