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

# Check if running in WSL
if command -v grep &> /dev/null && [ -f /proc/version ] && grep -qi microsoft /proc/version; then
    IS_WSL=true
    log "Detected WSL environment" "$YELLOW"
else
    IS_WSL=false
fi

# Parse command line arguments
ENV="dev"
while [[ $# -gt 0 ]]; do
    case $1 in
        --prod)
            ENV="prod"
            shift
            ;;
        *)
            log "Unknown option: $1" "$RED"
            log "Usage: $0 [--prod]" "$YELLOW"
            exit 1
            ;;
    esac
done

# Initial setup
if [ "$ENV" = "dev" ]; then
    log "🚀 Setting up My App development environment..." "$GREEN"
else
    log "🚀 Setting up My App production environment..." "$GREEN"
fi

# Install Docker if not present
# Check if Docker is installed and running
if ! command -v docker &> /dev/null || ! docker info &> /dev/null; then
    log "Installing Docker..." "$YELLOW"
    
    if [ "$IS_WSL" = true ]; then
        log "WSL detected - using alternative Docker installation method" "$YELLOW"
        # Install required packages
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Set up the stable repository
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        # Add current user to docker group
        sudo usermod -aG docker $USER
        
        log "Docker installed successfully in WSL. Please ensure Docker Desktop is installed on Windows and running." "$GREEN"
        log "After installation, you may need to log out and back in for group changes to take effect." "$GREEN"
    else
        # Install required packages
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Set up the stable repository
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        # Start Docker service
        sudo systemctl enable docker
        sudo systemctl start docker

        # Add current user to docker group
        sudo usermod -aG docker $USER
        log "Docker installed successfully. Please log out and back in for group changes to take effect." "$GREEN"
    fi
else
    log "Docker is already installed" "$GREEN"
fi

# Create necessary directories
log "Creating directories..." "$YELLOW"

mkdir -p data/api
mkdir -p data/backend
mkdir -p data/frontend
mkdir -p logs/nginx
mkdir -p logs/api
mkdir -p logs/backend
mkdir -p logs/app
    

# Set permissions
log "Setting permissions..." "$YELLOW"

chmod 755 data/api data/backend data/frontend
chmod 755 logs logs/nginx logs/api logs/backend logs/app
    

# Set up environment files
log "🔧 Setting up environment files..." "$YELLOW"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        # Generate secure keys and random string
        openssl rand -hex 32 > .env.secret
        SECURE_STRING=$(openssl rand -base64 96 | tr -dc 'a-zA-Z0-9' | head -c 128)
        echo "SECURE_STRING=$SECURE_STRING" >> .env
        chmod 600 .env.secret
        log "Created .env file from .env.example with secure keys" "$GREEN"
    else
        log "Warning: .env.example not found. Please create .env file manually." "$YELLOW"
    fi
else
    log ".env file already exists" "$GREEN"
fi

# Check if COMPOSE_PROJECT_NAME is already set in .env
if ! grep -q "COMPOSE_PROJECT_NAME" .env; then
    if [ "$ENV" = "dev" ]; then
        echo "COMPOSE_PROJECT_NAME=my-app-dev" >> .env
    else
        echo "COMPOSE_PROJECT_NAME=my-app-prod" >> .env
    fi
    log "Added COMPOSE_PROJECT_NAME to .env" "$GREEN"
else
    log "COMPOSE_PROJECT_NAME already exists in .env" "$GREEN"
fi

# Create empty log files to ensure proper permissions
log "Creating log files with proper permissions..." "$YELLOW"
touch logs/nginx/access.log logs/nginx/error.log
touch logs/api/api.log logs/backend/backend.log logs/app/app.log

# Set proper permissions for log files
chmod 666 logs/nginx/*.log  # Make log files writable by nginx user in container
chmod 644 logs/api/*.log logs/backend/*.log logs/app/*.log
    


# Set up log rotation
log "📝 Setting up log rotation..." "$YELLOW"
if [ -d "/etc/logrotate.d" ]; then
    # Check if config directory exists
    if [ ! -d "config" ]; then
        log "Warning: config directory not found. Creating basic config directory." "$YELLOW"
        mkdir -p config
    fi

    # Check if logrotate config files exist
    if [ "$ENV" = "dev" ]; then
        if [ ! -f "configmy-app-repo-dev-logrotate.conf" ]; then
            log "Creating development logrotate configuration..." "$YELLOW"
            cat > configmy-app-repo-dev-logrotate.conf << EOF
/path/to/project/logs/nginx/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        [ -s /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}

/path/to/project/logs/api/*.log /path/to/project/logs/backend/*.log /path/to/project/logs/app/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
}
EOF
            sed -i "s|/path/to/project|$(pwd)|g" configmy-app-repo-dev-logrotate.conf
        fi

        # Install logrotate config
        if [ -w "/etc/logrotate.d" ]; then
            sudo cp configmy-app-repo-dev-logrotate.conf /etc/logrotate.dmy-app-repo-dev
            log "Development log rotation configured" "$GREEN"
        else
            log "Warning: Cannot write to /etc/logrotate.d. Skipping logrotate setup." "$YELLOW"
            log "You may need to manually configure log rotation with sudo privileges." "$YELLOW"
        fi
    else
        if [ ! -f "configmy-app-repo-logrotate.conf" ]; then
            log "Creating production logrotate configuration..." "$YELLOW"
            cat > configmy-app-repo-logrotate.conf << EOF
/path/to/project/logs/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        [ -s /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}

/path/to/project/logs/api/*.log /path/to/project/logs/backend/*.log /path/to/project/logs/app/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
}
EOF
            sed -i "s|/path/to/project|$(pwd)|g" configmy-app-repo-logrotate.conf
        fi

        # Install logrotate config
        if [ -w "/etc/logrotate.d" ]; then
            sudo cp configmy-app-repo-logrotate.conf /etc/logrotate.dmy-app-repo
            log "Production log rotation configured" "$GREEN"
        else
            log "Warning: Cannot write to /etc/logrotate.d. Skipping logrotate setup." "$YELLOW"
            log "You may need to manually configure log rotation with sudo privileges." "$YELLOW"
        fi
    fi
else
    log "Logrotate directory not found. Skipping log rotation setup." "$YELLOW"
fi
    

# Build and start the containers
log "🏗️ Building and starting Docker containers..." "$YELLOW"

if [ "$ENV" = "dev" ]; then
    # Build and start development containers
    docker compose -f docker-compose.dev.yml build
    docker compose -f docker-compose.dev.yml up -d
else
    # Build and start production containers
    docker compose -f docker-compose.prod.yml build
    docker compose -f docker-compose.prod.yml up -d
fi


# Show running containers
log "📊 Current running containers:" "$GREEN"
if [ "$ENV" = "dev" ]; then
    docker compose -f docker-compose.dev.yml ps
else
    docker compose -f docker-compose.prod.yml ps
fi

if [ "$ENV" = "dev" ]; then

    log """
✅ Development setup complete! Your services are now running:
- Nginx: Running on http://localhost:8080
- API: Running on http://localhost:8000
- Backend: Running internally

Available sites:
- Main site: http://localhost:8080/

Logs are available in the ./logs directory:
- Nginx logs: ./logs/nginx/access.log and ./logs/nginx/error.log
- API logs: ./logs/api/api.log
- Backend logs: ./logs/backend/backend.log

To view logs:
- All services: docker compose logs -f
- Specific service: docker compose logs -f [service-name]
- Application logs: tail -f ./logs/*/*.log
- Nginx logs: tail -f ./logs/nginx/*.log

To stop services:
docker compose -f docker-compose.dev.yml down

To restart services:
docker compose -f docker-compose.dev.yml up -d
""" "$GREEN"
    
else
    log """
✅ Production setup complete! Your services are now running:
- Nginx: Running on port 80
- API: Running internally
- Backend: Running internally

Logs are available in the ./logs directory:
- Nginx logs: ./logs/nginx/
- API logs: ./logs/api.log
- Backend logs: ./logs/backend.log

To view logs:
- All services: docker compose logs -f
- Specific service: docker compose logs -f [service-name]
- Application logs: tail -f ./logs/*.log
- Nginx logs: tail -f ./logs/nginx/*.log

To stop services:
docker compose -f docker-compose.prod.yml down

To restart services:
docker compose -f docker-compose.prod.yml up -d
""" "$GREEN"
fi
