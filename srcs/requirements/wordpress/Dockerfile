FROM debian:bookworm

# php8.2-gd: provides image-processing functionality
# ca-certificates: installs the system's collection of trusted certificate authorities
RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-gd \
        php8.2-mbstring php8.2-xml php8.2-zip php8.2-intl \
        mariadb-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI: lets us install WordPress from a script, no browser wizard
# also entrypoint script can use WP-CLI to automate WordPress setup
# options passed to curl: -f: Treat certain HTTP error responses as failures; -s: Use silent mode
# -S: Show errors when silent mode is enabled; -L: Follow redirects
# -o /usr/local/bin/wp = write the downloaded file to that location
RUN curl -fsSL -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

# chown - Changes the ownership of the directory and its existing contents (-R: recursively)
RUN chmod +x /usr/local/bin/setup.sh \
    && mkdir -p /run/php /var/www/html \
    && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]