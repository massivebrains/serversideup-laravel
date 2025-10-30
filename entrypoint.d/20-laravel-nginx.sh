#!/bin/sh
set -e

echo "Adding laravel-port-80 Nginx config for port 80..."

# Adding a proxy to port 8080 so as to expose port 80 (using cap_net_bind_service=+ep)
cat > /etc/nginx/conf.d/laravel-port-80.conf <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        default_type text/plain;
        return 200 'OK';
    }
}
EOF
