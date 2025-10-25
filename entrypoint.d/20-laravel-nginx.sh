#!/bin/sh
set -e

echo "Adding laravel-port-80 Nginx config for ports 80 and 443..."

# Create a new Nginx config file since serverside-up runs un-privileged, If you check dockerfile, this is why it runs all .sh as root and then return to www-data
cat > /etc/nginx/conf.d/laravel-port-80.conf <<'EOF'
server {
    listen 80;
    listen 443;
    server_name _;
    charset utf-8;
    client_max_body_size 2048M;


    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location /health {
      default_type application/json;
      return 200 '{"code":"1", "message": "Hey im Healthy thanks to you!"}';
    }

    location ~ \.php$ {
        return 404;
    }

    location ~ /\.ht {
       deny  all;
    }
}
EOF

echo "Added /etc/nginx/conf.d/laravel-port-80.conf.conf"
