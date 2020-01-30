# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dlobos-m <dlobos-m@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/01/24 17:12:50 by dlobos-m          #+#    #+#              #
#    Updated: 2020/01/29 18:39:51 by dlobos-m         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update \
	&& apt-get -y install wget \
	&& apt-get -y install apt-utils \
	&& apt-get -y install nginx \
	&& apt-get -y install mariadb-server \
	&& apt-get -y install php-fpm php-mysql \
	&& apt-get -y install php-mbstring php-zip \
	php-gd php-xml php-pear php-gettext php-cgi \
	&& apt-get -y install libnss3-tools \
	&& apt-get -y install make \
	&& apt-get -y install golang \
	&& apt-get -y install curl 

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY srcs/default /etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/default etc/nginx/sites-enabled/

COPY srcs/phpMyAdmin-5.0.1-all-languages var/www/html/phpmyadmin
COPY srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
RUN chmod 660 var/www/html/phpmyadmin/config.inc.php && chown -R www-data:www-data /var/www/html/phpmyadmin
COPY srcs/phpmyadmin.sql ./

RUN cd /tmp && curl -LO https://wordpress.org/latest.tar.gz && tar xzvf /tmp/latest.tar.gz
COPY srcs/wp-config.php /tmp/wordpress/wp-config.php
RUN mkdir /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress
RUN cp -a /tmp/wordpress/. /var/www/html/wordpress

RUN cd /tmp && wget https://github.com/FiloSottile/mkcert/archive/v1.0.0.tar.gz && tar xzvf /tmp/v1.0.0.tar.gz
RUN cd /tmp/mkcert-1.0.0 && make
RUN cd /tmp/mkcert-1.0.0/bin && chmod +x mkcert
RUN cd /tmp/mkcert-1.0.0/bin && cp mkcert /usr/bin/
RUN mkcert -install && mkcert localhost

COPY srcs/index.html /var/www/html

EXPOSE 80 443 

ENTRYPOINT service php7.3-fpm start && service mysql start && mysql -u root < phpmyadmin.sql && service nginx start && sleep infinity && wait && bash