FROM jubicoy/nginx-php:php5-stable

RUN apt-get update \
  && apt-get install -y ruby ruby-dev rubygems git php5.6-mysql php5.6-dev \
    php5.6-xml php5.6-gd php-pear php5.6-mbstring php5.6-soap golang-go

RUN echo "clear_env = no" >> /etc/php/5.6/fpm/php-fpm.conf

RUN pecl channel-update pecl.php.net \
  && pecl install stats-1.0.3 \
  && echo "extension=stats.so" > /etc/php/5.6/mods-available/stats.ini

RUN gem install -N json \
  && gem install -N -v 0.12.0 prawn

RUN git clone https://github.com/PHPOffice/PHPExcel.git /usr/share/php/PHPExcel \
  && cd /usr/share/php/PHPExcel \
  && git checkout tags/1.7.9

RUN pear config-set preferred_state beta \
  && pear install OLE-1.0.0RC2 \
  && pear install Spreadsheet_Excel_Writer \
  && pear config-set preferred_state stable
  
RUN rm -rf /var/www/* \
  && git clone https://github.com/devlab-oy/pupesoft.git /var/www \
  && cd /var/www \
  && git checkout 315f1581b129c363fbc95326af79e9bc3d6c9150 \
  && mv /var/www/datain /workdir/datain \
  && mv /var/www/dataout /workdir/dataout

RUN mkdir -p /tmp/go/src/cron \
  && curl -o /tmp/go/src/cron/main.go https://raw.githubusercontent.com/jubicoy/cron/master/app/main.go \
  && cd /tmp/go/src/cron \
  && export GOPATH=/tmp/go \
  && go get \
  && go build -v -o /opt/bin/cron \
  && cd / \
  && rm -rf /tmp/go

COPY root /

RUN cd /var/www \
  && git apply logout.patch \
  && rm logout.patch \
  && mkdir /workdir/scripts \
  && cp *.sh /workdir/scripts \
  && ln -s /volume/datain /var/www/ \
  && ln -s /volume/dataout /var/www/ \
  && sed -i -e 's|POLKU=".*"|POLKU="/var/www/"|' /var/www/pupesoft.sh \
  && sed -i -e 's|BACKUPDIR=".*"|BACKUPDIR="/volume/pupe-backup"|' /var/www/pupesoft.sh \
  && sed -i -e 's|BACKUPDB=".*"|BACKUPDB=$MYSQL_DATABASE|' /var/www/pupesoft.sh \
  && sed -i -e 's|BACKUPUSER=".*"|BACKUPUSER=$MYSQL_USER|' /var/www/pupesoft.sh \
  && sed -i -e 's|BACKUPPASS=".*"|BACKUPUSER=$MYSQL_PASSWORD|' /var/www/pupesoft.sh

CMD ["/opt/bin/start-cmd"]
