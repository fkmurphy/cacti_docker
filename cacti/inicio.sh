#!/bin/sh
### Script de inicio para cacti
### Configura la base de datos y realiza la carga inicial

# Zona horaria en php.ini
echo "$(date +%F_%R) [Nota] Configurando PHP.INI con variable de ambiente TZ '${TZ}'"
sed -i -e "s/%TZ%/${TZ}/" /etc/php7/php.ini
#rm /etc/localtime
#ln -s /usr/share/zoneinfo/${TZ} /etc/localtime

#archivo de bloqueo - Si está instalado no vuelve a ejecutar
if [ ! -f /var/www/cacti/install.lock ]; then
    echo "$(date +%F_%R) [Nueva instalación] se comienza una instalación."

    # este script supone que ya se poseen los archivos en /var/www/cacti
#    echo "$(date +%F_%R) [New Install] Extracting and installing Spine files to /spine."
#    tar -xf /cacti_install/cacti-spine-*.tar.gz -C /tmp
#    cd /tmp/cacti-spine-* && \
#       ./configure --prefix=/spine && make && make install && \
#       chown root:root /spine/bin/spine && \
#       chmod +s /spine/bin/spine

    # Se reemplazan las configuraciones por los valores en las variables
    echo "$(date +%F_%R) [Nueva instalación] Actualizando archivos."
    sed -i -e "s/%DB_HOST%/${DB_HOST}/" \
           -e "s/%DB_PORT%/${DB_PORT}/" \
           -e "s/%DB_NAME%/${DB_NAME}/" \
           -e "s/%DB_USER%/${DB_USER}/" \
           -e "s/%DB_PASS%/${DB_PASS}/" \
           -e "s/%DB_PORT%/${DB_PORT}/" \
           -e "s/%RDB_HOST%/${RDB_HOST}/" \
           -e "s/%RDB_PORT%/${RDB_PORT}/" \
           -e "s/%RDB_NAME%/${RDB_NAME}/" \
           -e "s/%RDB_USER%/${RDB_USER}/" \
           -e "s/%RDB_PASS%/${RDB_PASS}/" \
        /var/www/cacti/include/config.php 

    echo "$(date +%F_%R) [Nueva instalación] Esperando a la base de datos ${DB_HOST}:${DB_PORT}. (puede tardar unos minutos)"
    # comprueba el estado de la base de datos
    count=0
    estado=1
    # comprobar estado de la bd
    while [ ! $estado -eq 0 ];
    #poner límite && [ $count -lt  10 ];
    do
        echo "[Nueva instalación] Intentando conectar a la base de datos (Intento $count)... "
        count=$(($count+1))
		# estado de la base de datos
        query=$(mysqladmin -h ${DB_HOST} -u root --password=${DB_ROOT_PASS} status)
		# estado de la base de datos a partir de una consulta sql
        #query=$(mysql -u root --password=${DB_ROOT_PASS} -h ${DB_HOST} -e  "SELECT 1")
        estado=$(echo $?)
        # esperar para volver a consultar
        sleep 10
    done
    
    # si el estado es OK -> 
    if [ $estado -eq 0 ]; then
        # crear DB por si no se creó
        echo "$(date +%F_%R) [Nueva instalación] CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        # FALTA INDICAR EL HOST PROPIO HTTP 
        mysql -u root -h ${DB_HOST} --port=${DB_PORT} --password=${DB_ROOT_PASS}  -e "grant select on mysql.time_zone_name to '${DB_USER}'@'%' identified by '${DB_PASS}'"
        mysql -h ${DB_HOST} --port=${DB_PORT} -uroot --password=${DB_ROOT_PASS} -e "CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        # Permitir acceso a el usuario
        echo "$(date +%F_%R) [Nueva instalación] GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}' IDENTIFIED BY '*******';"
        mysql -h ${DB_HOST} --port=${DB_PORT} -uroot --password=${DB_ROOT_PASS} -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
        # permitir acceso 
        echo "$(date +%F_%R) [Nueva instalación] GRANT SUPER ON *.* TO '${DB_USER}'@'%';"
        mysql -h ${DB_HOST} --port=${DB_PORT} -uroot --password=${DB_ROOT_PASS} -e "GRANT SUPER ON *.* TO '${DB_USER}'@'%';"
        # Permitir selección timezone
        echo "$(date +%F_%R) [Nueva instalación] GRANT SELECT ON mysql.time_zone_name TO '${DB_USER}' IDENTIFIED BY '*******';"
        mysql -h ${DB_HOST} --port=${DB_PORT} -uroot --password=${DB_ROOT_PASS} -e "GRANT SELECT ON mysql.time_zone_name TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
        
	    echo "$(date +%F_%R) [Nueva instalación] Importando CACTI.SQL."
        mysql -h ${DB_HOST} --port=${DB_PORT} -u${DB_USER} --password=${DB_PASS} ${DB_NAME} < /var/www/cacti/cacti.sql
    fi

    # CRON 
    echo '*/5 * * * * apache php /var/www/cacti/poller.php > /dev/null 2>&1' >> /etc/crontabs/root

    # Crear el archivo para bloquear instalación
    touch /var/www/cacti/install.lock
    echo "$(date +%F_%R) [Nueva instalación] Creando archivo de instalación. Configuración de DB completada"
fi

# correcting file permissions
echo "$(date +%F_%R) [Nota] Permisos en carpetas."
chown -R apache.apache /var/www/cacti/resource/
chown -R apache.apache /var/www/cacti/cache/
chown -R apache.apache /var/www/cacti/log/
chown -R apache.apache /var/www/cacti/scripts/
chown -R apache.apache /var/www/cacti/rra/


echo "$(date +%F_%R)  [Nota] Ejecutando crond en background"
crond -b

#FAIL OPENRC
#echo "$(date +%F_%R)  [Nota] Reload de snmpd"
#/etc/init.d/snmpd reload

# ejecutar servicio 
echo "$(date +%F_%R) [Nota] Ejecutando servicio HTTPD."
/usr/sbin/httpd -D FOREGROUND
