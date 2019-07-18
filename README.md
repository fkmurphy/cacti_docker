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
