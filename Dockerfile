FROM php:8.3-apache AS builder

WORKDIR /build

RUN curl -O https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz \
    && tar xzf dokuwiki-stable.tgz --strip-components=1 \
    && rm dokuwiki-stable.tgz \
    && curl -L https://github.com/reactivematter/dokuwiki-template-minimal/archive/master.tar.gz -o minimal.tgz \
    && mkdir -p lib/tpl/minimal \
    && tar xzf minimal.tgz --strip-components=1 -C lib/tpl/minimal \
    && rm minimal.tgz

COPY files/ .

FROM php:8.3-apache

LABEL maintainer="Eduardo N.S.R. <vndmtrx@duck.com>" \
      description="DokuWiki with pre-installed essential plugins and persistent storage support" \
      org.opencontainers.image.title="DokuWiki Docker Image" \
      org.opencontainers.image.description="DokuWiki with pre-installed essential plugins and persistent storage support" \
      org.opencontainers.image.authors="Eduardo N.S.R. <vndmtrx@duck.com>" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/vndmtrx/dokuwiki" \
      org.opencontainers.image.source="https://github.com/vndmtrx/dokuwiki-docker"

RUN apt-get update && apt-get install -y libldap2-dev libzip-dev ldap-utils vim \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap zip \
    && a2enmod rewrite \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives -type f -delete

RUN { \
    echo 'output_buffering = 4096'; \
    echo 'memory_limit = 256M'; \
    echo 'max_execution_time = 60'; \
    echo 'upload_max_filesize = 50M'; \
    echo 'post_max_size = 50M'; \
    } > /usr/local/etc/php/conf.d/dokuwiki.ini

WORKDIR /var/www/html

COPY --from=builder /build/ .
RUN mkdir /dokuwiki \
    && chown -R www-data:www-data . /dokuwiki

COPY init-script.sh /usr/local/bin/init-script.sh
RUN chmod +x /usr/local/bin/init-script.sh

EXPOSE 80

VOLUME ["/dokuwiki"]

USER www-data

ENTRYPOINT ["/usr/local/bin/init-script.sh"]