FROM php:8.2-apache

# Install PDO MySQL extension for database connection
RUN docker-php-ext-install pdo pdo_mysql

# Enable Apache mod_rewrite for routing
RUN a2enmod rewrite

# Copy backend files to the web root
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Expose port 80
EXPOSE 80
