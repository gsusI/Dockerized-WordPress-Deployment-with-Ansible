#!/bin/bash

# Configure PHP-FPM to listen on all interfaces
sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /usr/local/etc/php-fpm.d/www.conf

# Start PHP-FPM in the background
php-fpm &

# Wait a bit to ensure PHP-FPM is up
sleep 5

# Send a test email using ssmtp
echo -e "To: jesus.inica@gmail.com\nFrom: wordpress@example.com\nSubject: Test Email\n\nThis is a test email from Docker container." | ssmtp jesus.inica@gmail.com

# Keep the container running
wait
