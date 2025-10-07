FROM php:8.1-apache

# Install Sendy required PHP extensions
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libgettextpo-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo_mysql \
        zip \
        gd \
        mbstring \
        xml \
        curl \
        gettext \
        simplexml && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite && \
    echo "\
<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog \${APACHE_LOG_DIR}/error.log\n\
    CustomLog \${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# PHP config
RUN { \
    echo 'max_execution_time = 30'; \
    echo 'ignore_user_abort = Off'; \
    echo 'display_errors = On'; \
    echo 'error_reporting = E_ALL'; \
    echo 'log_errors = On'; \
    echo 'error_log = /dev/stderr'; \
    echo 'session.save_path = "/tmp"'; \
    } > /usr/local/etc/php/conf.d/sendy.ini

# Copy Sendy files
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    mkdir -p /var/www/html/uploads /var/www/html/uploads/logos /var/www/html/uploads/attachments /var/www/html/uploads/templates && \
    chmod -R 777 /var/www/html/uploads && \
    mkdir -p /tmp && chmod -R 777 /tmp

EXPOSE 80

CMD ["apache2-foreground"]
