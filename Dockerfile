FROM php:8.3-apache

LABEL maintainer="Eduardo N.S.R. <vndmtrx@duck.com>" \
      description="DokuWiki with essential plugins" \
      org.opencontainers.image.title="DokuWiki Docker Image" \
      org.opencontainers.image.description="DokuWiki with pre-installed essential plugins and persistent storage support" \
      org.opencontainers.image.authors="Eduardo N.S.R. <vndmtrx@duck.com>" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="AGPL-3.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/vndmtrx/dokuwiki" \
      org.opencontainers.image.source="https://github.com/vndmtrx/dokuwiki-docker" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/vndmtrx/dokuwiki"

RUN apt-get update && apt-get install -y \
    libldap2-dev \
    libzip-dev \
    ldap-utils \
    nano \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap zip \
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

RUN curl -O https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz \
    && tar xzf dokuwiki-stable.tgz --strip-components=1 \
    && rm dokuwiki-stable.tgz

RUN curl -L https://github.com/reactivematter/dokuwiki-template-minimal/archive/master.tar.gz -o minimal.tgz \
    && mkdir -p lib/tpl/minimal \
    && tar xzf minimal.tgz --strip-components=1 -C lib/tpl/minimal \
    && rm minimal.tgz \
    && chown -R www-data:www-data . \
    && a2enmod rewrite

COPY --chown=www-data:www-data files/ .

RUN mkdir -p /dokuwiki \
    && ln -s /dokuwiki/conf conf \
    && ln -s /dokuwiki/data data \
    && ln -s /dokuwiki/plugins lib/plugins \
    && ln -s /dokuwiki/tpl lib/tpl

EXPOSE 80

VOLUME ["/dokuwiki"]

USER www-data