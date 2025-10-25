# ServerSideUp Laravel Container

A comprehensive Docker container setup for Laravel applications using the ServerSideUp PHP base image with integrated support for Laravel Horizon, Scheduler, and Nightwatch.

## 🚀 Overview
This repository provides a production-ready Docker container configuration for Laravel applications, built on top of the `serversideup/php:8.4-fpm-nginx` base image. The container includes:

> 📚 **For more detailed documentation about ServerSideUp containers and configuration options, visit the [ServerSideUp Documentation](https://serversideup.net/open-source/docker-php/docs).**

- **Laravel Compatible base Image** with PHP 8.4 and Nginx
- **Laravel Horizon** for queue management
- **Laravel Scheduler** for cron job execution
- **Nightwatch** for end-to-end testing
- **Port 80/443 exposure** with custom Nginx configuration

## 📋 Prerequisites
- Docker and Docker Compose
- Laravel application with the following artisan commands available:
  - `php artisan horizon`
  - `php artisan schedule:work`
  - `php artisan nightwatch:agent`

## 🏗️ Project Structure

```
serversideup-laravel/
├── Dockerfile                          # Main container configuration
├── entrypoint.d/
│   ├── 20-laravel-nginx.sh            # Nginx configuration script
│   └── laravel/                       # S6 service definitions
│       ├── nightwatch/
│       │   ├── run                    # Nightwatch service runner
│       │   └── type                   # Service type definition
│       ├── queue/
│       │   ├── run                    # Horizon service runner
│       │   └── type                   # Service type definition
│       ├── schedule/
│       │   ├── run                    # Scheduler service runner
│       │   └── type                   # Service type definition
│       └── user/
│           └── contents.d/            # Service dependencies
│               ├── nightwatch
│               ├── queue
│               └── schedule
└── README.md
```

## 🔧 Configuration

### Dockerfile Features

The Dockerfile is configured to:

1. **Base Image**: Uses `serversideup/php:8.4-fpm-nginx` for PHP 8.4 with Nginx
2. **Working Directory**: Sets `/var/www/html` as the application root
3. **Dependencies**: Installs Composer dependencies with optimization
4. **Permissions**: Sets proper ownership and permissions for Laravel directories
5. **Services**: Configures S6 overlay services for process management
6. **Ports**: Exposes ports 80 and 8080

### Nginx Configuration

The `20-laravel-nginx.sh` script creates a custom Nginx configuration that:

- **Listens on ports 80 and 443** (HTTP and HTTPS)
- **Serves Laravel application** from `/var/www/html/public`
- **Handles PHP processing** via FastCGI on port 9000
- **Includes health check endpoint** at `/health`
- **Sets client max body size** to 2048M for file uploads
- **Implements security measures** (denies .htaccess files)

### Service Management

The container uses S6 overlay for process management with three main services:

#### 1. Laravel Horizon (`queue`)
- **Purpose**: Manages Laravel queues and background jobs
- **Command**: `php artisan horizon`
- **Type**: Long-running service
- **Dependencies**: Configured in `user/contents.d/queue`

#### 2. Laravel Scheduler (`schedule`)
- **Purpose**: Executes scheduled tasks and cron jobs
- **Command**: `php artisan schedule:work`
- **Type**: Long-running service
- **Dependencies**: Configured in `user/contents.d/schedule`

#### 3. Nightwatch Testing (`nightwatch`)
- **Purpose**: Runs end-to-end tests
- **Command**: `php artisan nightwatch:agent`
- **Type**: Long-running service
- **Dependencies**: Configured in `user/contents.d/nightwatch`

## 🚀 Usage
Simply add the files in this repo to your Laravel application root.

### Building the Container

```bash
# Build the Docker image
docker build -t app .

# Or with a specific tag
docker build -t app:latest .
```

### Running the Container

```bash
# Run the container
docker run -d \
  --name app \
  -p 80:80 \
  -p 8080:8080 \
  serversideup-laravel

# Run with environment variables
docker run -d \
  --name app \
  -p 80:80 \
  -p 8080:8080 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  serversideup-laravel
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  laravel-app:
    build: .
    container_name: serversideup-laravel
    ports:
      - "80:80"
      - "8080:8080"
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    volumes:
      - ./storage:/var/www/html/storage
      - ./bootstrap/cache:/var/www/html/bootstrap/cache
    restart: unless-stopped
```

Then run:

```bash
docker-compose up -d
```

## 🔍 Health Check

The container includes a health check endpoint at `/health` that returns:

```json
{
  "code": "1",
  "message": "Hey i'm Healthy thanks to you!"
}
```

## 📝 Laravel Setup Requirements

Ensure your Laravel application has the following artisan commands available:

### Horizon Setup
```bash
# Install Horizon
composer require laravel/horizon

# Publish Horizon configuration
php artisan horizon:install

# Start Horizon (handled by container)
php artisan horizon
```

### Scheduler Setup
```bash
# Define scheduled tasks in app/Console/Kernel.php
# The container runs: php artisan schedule:work
```

### Nightwatch Setup
```bash
# Install Nightwatch (if not already installed)
npm install --save-dev nightwatch

# Create custom artisan command for nightwatch:agent
# This should be implemented in your Laravel application
```

## 🛠️ Customization

### Environment Variables

The container supports standard Laravel environment variables. Create a `.env` file or pass them via Docker:

```bash
# Database
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=password

# Queue
QUEUE_CONNECTION=redis

# Cache
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

### Volume Mounts

For development, you may want to mount your source code:

```bash
docker run -d \
  --name laravel-app \
  -p 80:80 \
  -v $(pwd):/var/www/html \
  serversideup-laravel
```

## 🔒 Security Considerations

- The container runs as `www-data` user for security
- Nginx configuration denies access to `.htaccess` files
- Proper file permissions are set on Laravel directories
- The container uses unprivileged mode for enhanced security

## 📊 Monitoring

The container runs multiple services simultaneously:

- **Nginx**: Web server on port 80/443
- **PHP-FPM**: PHP processing on port 9000
- **Horizon**: Queue management
- **Scheduler**: Cron job execution
- **Nightwatch**: Monitoring

Monitor these services using:

```bash
# Check container logs
docker logs app

# Check specific service logs
docker exec app s6-svstat /var/run/s6/services/horizon
docker exec app s6-svstat /var/run/s6/services/schedule
docker exec app s6-svstat /var/run/s6/services/nightwatch
```

## 🤝 Contributing

This container setup is designed to be flexible and extensible. Feel free to:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

## 👨‍💻 Author

Created by **massivebrains** - A comprehensive Laravel containerization solution for modern web applications.

---

## 🆘 Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure your Laravel application has proper file permissions
2. **Service Not Starting**: Check that your Laravel application has the required artisan commands
3. **Port Conflicts**: Make sure ports 80 and 8080 are available on your host system

### Debug Commands

```bash
# Enter the container
docker exec -it laravel-app bash

# Check service status
docker exec laravel-app s6-svstat /var/run/s6/services/*

# View Nginx configuration
docker exec laravel-app cat /etc/nginx/conf.d/laravel-port-80.conf

# Check Laravel logs
docker exec laravel-app tail -f /var/www/html/storage/logs/laravel.log
```
