FROM serversideup/php:8.4-fpm-nginx
WORKDIR /var/www/html
COPY . .
COPY .env.example .env
USER root
RUN apt-get update && apt-get install -y --no-install-recommends git unzip ca-certificates libcap2-bin && rm -rf /var/lib/apt/lists/*
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx
RUN composer install --no-scripts --no-autoloader && composer dump-autoload --optimize --no-scripts
RUN chown -R www-data:www-data storage bootstrap/cache public && chmod -R ug+rwx storage bootstrap/cache public
ENV AUTORUN_ENABLED=true PHP_OPCACHE_ENABLE=1
COPY --chmod=755 ./entrypoint.d/laravel/ /etc/s6-overlay/s6-rc.d/
COPY --chmod=755 ./entrypoint.d/ /etc/entrypoint.d/
USER www-data
HEALTHCHECK CMD curl --silent --insecure --show-error -f http://localhost/health || exit 1
EXPOSE 80 8080
