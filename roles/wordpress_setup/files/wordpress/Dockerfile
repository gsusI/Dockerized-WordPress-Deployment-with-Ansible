FROM wordpress:fpm

# Install additional PHP modules
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Update and reinstall sendmail, clean up in one layer to reduce image size
RUN apt-get update && \
    apt-get install -y sendmail && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# Custom PHP configurations can be added here
COPY php.ini /usr/local/etc/php/

# Copy the start script and make it executable
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose port 9000
EXPOSE 9000

# Set the start script as the entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]