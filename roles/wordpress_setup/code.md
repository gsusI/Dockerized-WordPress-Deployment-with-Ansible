# tasks\main.yml
```
---
- name: Create WordPress directory
  file:
    path: /opt/wordpress
    state: directory

- name: Synchronize files
  synchronize:
    src: ./files/
    dest: /opt/wordpress
    recursive: yes
  notify: Restart Docker

- name: Debug Nginx Configuration
  shell: ls -l /opt/wordpress/nginx
  args:
    chdir: /opt/wordpress/
  register: debug_output
  ignore_errors: true

- debug:
    var: debug_output.stdout_lines

- name: Ensure php.ini exists in php-fpm build context
  copy:
    src: ./files/wordpress/php.ini
    dest: /opt/wordpress/wordpress/php.ini
  notify: Restart Docker

- name: Check if WordPress services are running
  shell: cd /opt/wordpress && docker-compose ps | grep wordpress
  register: service_check
  ignore_errors: true

- name: Deploy WordPress stack
  command: docker-compose -f /opt/wordpress/docker-compose.yml up -d
  args:
    chdir: /opt/wordpress/
  when: service_check.rc != 0
  notify:
    - Restart Docker
    - Reload WordPress stack

```
# files\docker-compose.yml
```
version: '3.9'

services:
  wordpress:
    build: ./wordpress
    container_name: wordpress_fpm
    env_file:
      - ./wordpress.env
    depends_on:
      - mariadb
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - wp_network

  mariadb:
    container_name: mariadb
    image: mariadb:latest
    env_file:
      - ./mariadb.env
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - wp_network 

  nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - wordpress_data:/var/www/html
    ports:
      - "80:80"
    depends_on:
      - wordpress
    networks:
      - wp_network

volumes:
  wordpress_data:
  mariadb_data:

networks:
  wp_network:
    driver: bridge
```
# files\mariadb.env
```
MARIADB_ROOT_PASSWORD=rootsecret
MARIADB_DATABASE=wordpress
MARIADB_USER=wordpress
MARIADB_PASSWORD=secret

```
# files\wordpress.env
```
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wordpress
WORDPRESS_DB_PASSWORD=secret

```
# files\wordpress\Dockerfile
```
FROM wordpress:fpm

# # Install additional PHP modules
# RUN docker-php-ext-install mysqli pdo pdo_mysql

# # Custom PHP configurations can be added here
# COPY php.ini /usr/local/etc/php/

# # Copy the start script and make it executable
# COPY start.sh /usr/local/bin/start.sh
# RUN chmod +x /usr/local/bin/start.sh

# # Expose port 9000
# EXPOSE 9000

# # Set the start script as the entrypoint
# ENTRYPOINT ["start.sh"]
```
# files\wordpress\php.ini
```
; php.ini
display_errors = Off
log_errors = On

```
# files\wordpress\start.sh
```
#!/bin/bash
sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /usr/local/etc/php-fpm.d/www.conf
php-fpm
```
# files\nginx\Dockerfile
```
FROM nginx:latest

# Custom Nginx configurations
COPY nginx.conf /etc/nginx/nginx.conf

```
# files\nginx\nginx.conf
```
events {
    worker_connections 1024;
}
http {
  server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.php;

    location / {
      try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
      fastcgi_pass wordpress:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
      expires max;
      log_not_found off;
    }
  }
}

```
# handlers\main.yml
```
---
- name: Restart Docker
  command: docker-compose -f /opt/wordpress/docker-compose.yml down && docker-compose -f /opt/wordpress/docker-compose.yml up -d
  args:
    chdir: /opt/wordpress/

- name: Reload WordPress stack
  block:
    - name: Bring down the WordPress stack
      command: docker-compose -f /opt/wordpress/docker-compose.yml down
      args:
        chdir: /opt/wordpress/

    - name: Rebuild and bring up the WordPress stack
      command: docker-compose -f /opt/wordpress/docker-compose.yml up --build -d
      args:
        chdir: /opt/wordpress/
```
