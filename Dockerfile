FROM wordpress:fpm
# Would be preferable to use Alpine, but it seems the latest image versions aren't made for it anymore...
LABEL e-labo=hello@e-labo.io

COPY install-plugins.sh /usr/local/bin/install-plugins.sh
RUN sed -i 's/\r//g' /usr/local/bin/install-plugins.sh
COPY wp_post_entrypoint.sh /usr/local/bin/wp_post_entrypoint
RUN sed -i 's/\r//g' /usr/local/bin/wp_post_entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r//g' /usr/local/bin/docker-entrypoint.sh
    # Remove Windows carriage return

# Install WordPress plugins
RUN chmod +x /usr/local/bin/install-plugins.sh &&\
    chmod +x /usr/local/bin/wp_post_entrypoint &&\
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Install WordPress CLI
RUN apt-get update
RUN apt-get install -y unzip git curl sudo default-mysql-client &&\
    cd /tmp && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && cd &&\
    chmod +x /tmp/wp-cli.phar &&\
    mv /tmp/wp-cli.phar /usr/local/bin/wp &&\
    apt-get remove -y curl git &&\
    apt-get clean

EXPOSE 9000

ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]
