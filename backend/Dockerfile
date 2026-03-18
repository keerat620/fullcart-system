FROM php:8.2-apache

# Install PDO MySQL and PostgreSQL extensions
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_mysql pdo_pgsql

# Enable Apache mod_rewrite for routing
RUN a2enmod rewrite

# Copy backend files to the web root
COPY backend/ /var/www/html/

# Set permissions for uploads
RUN chown -R www-data:www-data /var/www/html

# Set working directory
WORKDIR /var/www/html/

# Expose port 80
EXPOSE 80
