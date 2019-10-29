#!/bin/sh
while [ 1 -le 1 ] ;
do
	/usr/bin/php7 /var/www/cacti/poller.php
	echo "ejecute php7 poller" 
	sleep 300
done
