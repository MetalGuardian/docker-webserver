FROM ubuntu:14.04.1
MAINTAINER Ivan Pushkin <imetalguardi+docker@gmail.com>

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV TERM xterm
ENV MYSQL_USER root
ENV MYSQL_PASSWORD ""
ENV MYSQL_MAJOR 5.6
ENV HOSTNAME docker.dev

# add php configuration file in specified position
COPY configs/custom.php.ini /etc/php5/mods-available/custom.ini

RUN \

# utf locale
	locale-gen $LC_ALL && \

# add nginx repository
	apt-key adv --keyserver pgp.mit.edu --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
	echo "deb http://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list && \

# add mysql repository
	apt-key adv --keyserver pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 && \
	echo "deb http://repo.mysql.com/apt/ubuntu/ $(lsb_release -cs) mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list && \

# add ondrej php repository
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
	echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" > /etc/apt/sources.list.d/php.list && \

# add chrome repository
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A040830F7FAC5991 && \
	echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \

# update
	apt-get update && \

# install all packages
	DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install \
		nano \
		bash-completion \
		openssl \
		ca-certificates \
		nginx \
		supervisor \
		mysql-server \
		mysql-client \
		curl \
		wget \
		git \
		sqlite3 \
		php5-fpm \
		php5-cli \
		php5-mysql \
		php5-curl \
		php5-gd \
		php5-intl \
		php5-imagick \
		php5-mcrypt \
		php5-memcached \
		php5-json \
		php-pear \
		php5-dev \
		php5-xdebug \
		php5-sqlite \
		phpmyadmin \
# install dev env for selenium tests
		firefox \
		google-chrome-stable \
		openjdk-7-jre-headless \
		x11vnc \
		xvfb \
		xfonts-100dpi \
		xfonts-75dpi \
		xfonts-scalable \
		xfonts-cyrillic \
		unzip \
		fluxbox && \

# install composer
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

# add user "docker" to use it as default user for working with files
	yes "" | adduser --uid=1000 --disabled-password docker && \
	echo "docker   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \

# install composer assets plugin
	sudo -H -u docker bash -c "/usr/local/bin/composer global require fxp/composer-asset-plugin:1.0.0" && \

# create and set access to the folder
	mkdir -p /web/docker && \
	echo "<?php echo 'web server is running';" > /web/docker/index.php && \
	chown -R docker:docker /web && \

# add custom php configuration
	php5enmod custom && \

# enable mcrypt module
	php5enmod mcrypt && \

# set access and error nginx logs to stdout and stderr
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log && \

# set where to store vnc password
#	x11vnc -storepasswd secret ~/.vnc/passwd && \

# install chromedriver
	wget --no-verbose https://chromedriver.googlecode.com/files/chromedriver_linux64_2.2.zip -O /tmp/chromedriver.zip && \
	unzip /tmp/chromedriver.zip -d /tmp/ && \
	rm /tmp/chromedriver.zip && \
	mv /tmp/chromedriver /usr/bin/chromedriver && \

# download selenium standalone
	wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar -O /opt/selenium-server-standalone.jar && \

# clean apt cache and temps
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add supervisord configuration file 
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# add mysql start script
COPY configs/mysql.sh /opt/mysql.sh

# add selenium starter script
COPY configs/tests.sh /opt/tests.sh

# replace php-fpm configuration file
COPY configs/php-fpm.conf /etc/php5/fpm/php-fpm.conf

# add phpmyadmin configuration file 
COPY configs/phpmyadmin.php /etc/phpmyadmin/conf.d/phpmyadmin.php

# replace nginx virtual host configuration file
COPY configs/default.conf /etc/nginx/conf.d/default.conf

COPY configs/xdebug.ini /etc/php5/mods-available/xdebug.ini

EXPOSE 80 443 3306 9000 4444 5900 9001

VOLUME ["/web", "/var/lib/mysql"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
