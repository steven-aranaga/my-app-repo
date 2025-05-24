#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Log function
log() {
    echo -e "${2}${1}${NC}"
}

log "🚀 Starting My App in development mode..." "${GREEN}"

# Create necessary directories if they don't exist
log "Creating directories..." "${YELLOW}"
mkdir -p /app/data
mkdir -p /app/logs
mkdir -p /app/static/css
mkdir -p /app/static/js
mkdir -p /app/static/html

# Copy static files if they don't exist
if [ ! -f "/app/static/css/styles.css" ]; then
    log "Copying static files..." "${YELLOW}"
    cp -r /workspace/static/* /app/static/
fi

# Set up environment file if it doesn't exist
if [ ! -f "/app/.env" ]; then
    log "Setting up environment file..." "${YELLOW}"
    if [ -f "/workspace/.env.example" ]; then
        cp /workspace/.env.example /app/.env
        log "Created .env file from .env.example" "${GREEN}"
    else
        log "Warning: .env.example not found. Creating basic .env file." "${YELLOW}"
        cat > /app/.env << EOF
# Environment
ENVIRONMENT=development

# API settings
API_TOKEN=dev_api_token
JWT_SECRET=dev_jwt_secret
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Web settings
WEB_HOST=0.0.0.0
WEB_PORT=3000

# API settings
API_HOST=0.0.0.0
API_PORT=8000

# Backend settings
DATABASE_URL=sqlite:///app/data/app.db
LOG_LEVEL=debug
LOG_FILE=/app/logs/backend.log
EOF
    fi
fi

# Set up Python environment
log "Setting up Python environment..." "${YELLOW}"
if [ ! -d "/app/venv" ]; then
    python3 -m venv /app/venv
fi
source /app/venv/bin/activate
pip install --upgrade pip
pip install -r /workspace/backend/requirements.txt

# Build Rust applications
log "Building Rust applications..." "${YELLOW}"
cd /workspace/api
cargo build

cd /workspace/web
cargo build

# Initialize database if it doesn't exist
if [ ! -f "/app/data/app.db" ]; then
    log "Initializing database..." "${YELLOW}"
    cd /workspace
    PYTHONPATH=/workspace python3 -c "from backend.app.db import init_db; init_db()"
    log "Database initialized" "${GREEN}"
fi

# Start services using supervisor
log "Starting services..." "${YELLOW}"

# Create supervisor configuration
cat > /tmp/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/app/logs/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/tmp/supervisord.pid

[program:backend]
command=/app/venv/bin/python /workspace/backend/main.py
directory=/workspace/backend
autostart=true
autorestart=true
startretries=5
numprocs=1
startsecs=5
stdout_logfile=/app/logs/backend_stdout.log
stderr_logfile=/app/logs/backend_stderr.log
environment=PYTHONPATH="/workspace"

[program:api]
command=/workspace/api/target/debug/api
directory=/workspace/api
autostart=true
autorestart=true
startretries=5
numprocs=1
startsecs=5
stdout_logfile=/app/logs/api_stdout.log
stderr_logfile=/app/logs/api_stderr.log

[program:web]
command=/workspace/web/target/debug/web
directory=/workspace/web
autostart=true
autorestart=true
startretries=5
numprocs=1
startsecs=5
stdout_logfile=/app/logs/web_stdout.log
stderr_logfile=/app/logs/web_stderr.log

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
startretries=5
numprocs=1
startsecs=0
stdout_logfile=/app/logs/nginx_stdout.log
stderr_logfile=/app/logs/nginx_stderr.log
EOF

# Configure Nginx
cat > /tmp/nginx.conf << EOF
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip compression
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    
    # Main server block
    server {
        listen 80;
        server_name localhost;
        
        # Frontend
        location / {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_cache_bypass \$http_upgrade;
        }
        
        # API
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://localhost:8000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_cache_bypass \$http_upgrade;
        }
        
        # Static files
        location /static/ {
            alias /workspace/static/;
            expires 1d;
            add_header Cache-Control "public, max-age=86400";
        }
        
        # Error pages
        error_page 404 /404.html;
        location = /404.html {
            root /workspace/static/html;
            internal;
        }
        
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /workspace/static/html;
            internal;
        }
    }
}
EOF

# Copy Nginx configuration
if [ -f "/etc/nginx/nginx.conf" ]; then
    cp /tmp/nginx.conf /etc/nginx/nginx.conf
fi

# Start supervisor
log "Starting supervisor..." "${GREEN}"
supervisord -c /tmp/supervisord.conf

# Show running services
log "
✅ Development setup complete! Your services are now running:
- Nginx: Running on http://localhost:80
- API: Running on http://localhost:8000
- Web: Running on http://localhost:3000
- Backend: Running internally

Available sites:
- Main site: http://localhost/

Logs are available in the /app/logs directory:
- Nginx logs: /app/logs/nginx_*.log
- API logs: /app/logs/api_*.log
- Web logs: /app/logs/web_*.log
- Backend logs: /app/logs/backend_*.log

To view logs:
- All services: tail -f /app/logs/*.log
" "${GREEN}"

# Keep the script running to prevent container exit
tail -f /app/logs/*.log

