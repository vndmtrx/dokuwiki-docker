FROM php:8.3-apache

LABEL maintainer="Eduardo N.S.R. <vndmtrx@duck.com>" \
      description="DokuWiki with essential plugins" \
      org.opencontainers.image.title="DokuWiki Docker Image" \
      org.opencontainers.image.description="DokuWiki with essential plugins pre-installed and persistent storage support" \
      org.opencontainers.image.authors="Eduardo N.S.R. <vndmtrx@duck.com>" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/vndmtrx/dokuwiki" \
      org.opencontainers.image.source="https://github.com/vndmtrx/dokuwiki-docker" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/vndmtrx/dokuwiki"

ENV OS_NAME="debian" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="bookworm" \
    APP_VERSION="stable" \
    BITNAMI_APP_NAME="dokuwiki"

RUN apt-get update && apt-get install -y \
    libldap2-dev \
    libzip-dev \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap zip \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives -type f -delete

WORKDIR /var/www/html

RUN mkdir /dokuwiki \
    && curl -O https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz \
    && tar xzf dokuwiki-stable.tgz --strip-components=1 \
    && rm dokuwiki-stable.tgz \
    && mv conf /dokuwiki/ \
    && mv data /dokuwiki/ \
    && mv lib/plugins /dokuwiki/plugins \
    && mv lib/tpl /dokuwiki/tpl \
    && ln -s /dokuwiki/conf conf \
    && ln -s /dokuwiki/data data \
    && ln -s /dokuwiki/plugins lib/plugins \
    && ln -s /dokuwiki/tpl lib/tpl \
    && chown -R www-data:www-data /var/www/html /dokuwiki \
    && a2enmod rewrite

RUN { \
    echo 'upload_max_filesize = 16M'; \
    echo 'post_max_size = 16M'; \
    echo 'memory_limit = 128M'; \
} > /usr/local/etc/php/conf.d/dokuwiki.ini

EXPOSE 80

VOLUME ["/dokuwiki"]

USER www-data