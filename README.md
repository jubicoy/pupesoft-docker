# Dockerized Pupesoft

## Email Configuration - ENV Variables
* SMTP_HOST
* SMTP_PORT
* SMTP_USER
* SMTP_PASSWORD
* SMTP_FROM_EMAIL

## Database Configuration - ENV Variables
* MYSQL_USER
* MYSQL_PASSWORD
* MYSQL_DATABASE
* MYSQL_HOST

## Other ENV Variables
* SERVER (domain name to access the server with)
* TASK_pupesoft_scheduled_task (cron example value: '0 0 23 * * *|sh /var/www/pupesoft.sh')