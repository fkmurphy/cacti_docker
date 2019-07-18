## Cacti en Docker 

### Instalación
**1. Crear envs**

mysql.env:

```env
MYSQL_ROOT_PASSWORD=cacti
MYSQL_DATABASE=cacti
MYSQL_USER=cacti
MYSQL_PASSWORD=cacti
```

cacti.env
```env
DB_NAME=cacti 
DB_USER=cacti
DB_PASS=cacti
DB_HOST=mysql
DB_PORT=3306 
DB_ROOT_PASS=cacti
TZ="America/Argentina/Buenos_Aires"
```

**2. Descargar cacti y descomprimir dentro de la carpeta cacti/data**

**3. Ejecutar**
```bash
$ docker-compose build
$ docker-compose up -d
```

**4. Abrir el navegador 127.0.0.1:8084 y seguir los pasos de instalación**

> Utilizar la versión 1.7.2+ de RDtools


### Sobre script inicio.sh
El estado del servicio mysql se comprueba mediante el siguiente trozo de código dentro del script inicio.sh. 
```bash
    # comprueba el estado de la base de datos
    
    # no se está utilizando count
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
```
Si se quiere comprobar mediante una consulta se puede reemplazar la siguiente línea
```bash
query=$(mysqladmin -h ${DB_HOST} -u root --password=${DB_ROOT_PASS} status)
```
por esto:
```bash
query=$(mysql -u root --password=${DB_ROOT_PASS} -h ${DB_HOST} -e  "SELECT 1")
```
Al finalizar la configuración e importanción de la base de datos (esto incluye cacti.sql) se crea un archivo llamado install.lock dentro del directorio de cacti. Este archivo es necesario para que la instalación de inicio.sh no vuelva a ejecutarse.
