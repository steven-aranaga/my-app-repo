#!/bin/bash

alias ll='ls -lhA'

# Exit on error
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

# Print starting directory for debugging
echo "Starting directory: $(pwd)"

# Change into the repository directory
cd /workspacemy-app-repo

# Print current directory after cd
echo "Current directory: $(pwd)"

# Install system dependencies
log "Installing system dependencies..." "$YELLOW"
sudo apt-get update
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    nginx \
    git \
    logrotate

# Install Rust if not present
if ! command -v rustc &> /dev/null; then
    log "Installing Rust..." "$YELLOW"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Create Python virtual environment
log "Setting up Python virtual environment..." "$YELLOW"
if [ -d "venv" ]; then
    log "Removing existing virtual environment..." "$YELLOW"
    rm -rf venv
fi

# Ensure python3-venv is installed
if ! dpkg -l | grep -q python3-venv; then
    log "Installing python3-venv..." "$YELLOW"
    sudo apt-get install -y python3-venv
fi

# Create new virtual environment
log "Creating new virtual environment..." "$YELLOW"
python3 -m venv venv --clear || {
    log "Failed to create virtual environment. Checking Python installation..." "$RED"
    python3 --version
    which python3
    log "Please ensure python3 and python3-venv are properly installed" "$RED"
    exit 1
}

# Activate virtual environment
log "Activating virtual environment..." "$YELLOW"
source venv/bin/activate || {
    log "Failed to activate virtual environment" "$RED"
    exit 1
}

# Ensure pip is up to date
log "Updating pip..." "$YELLOW"
python3 -m pip install --upgrade pip || {
    log "Failed to upgrade pip. Attempting to install pip..." "$YELLOW"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
}

# Install Python dependencies
log "Installing Python dependencies..." "$YELLOW"
pip install -r requirements.txt

# Install Rust dependencies
log "Installing Rust dependencies..." "$YELLOW"
# Find all Cargo.toml files and build them
find . -name "Cargo.toml" -type f | while read -r cargo_file; do
    dir=$(dirname "$cargo_file")
    log "Building Rust project in $dir..." "$YELLOW"
    (cd "$dir" && cargo build)
done

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
log "Setting up environment files..." "$YELLOW"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        # Generate secure keys
        openssl rand -hex 32 > .env.secret
        SECURE_STRING=$(openssl rand -base64 96 | tr -dc 'a-zA-Z0-9' | head -c 128)
        echo "SECURE_STRING=$SECURE_STRING" >> .env
        chmod 600 .env.secret
        log "Created .env file from .env.example with secure keys" "$GREEN"
    else
        log "Warning: .env.example not found. Please create .env file manually." "$YELLOW"
    fi
fi

# Configure Nginx
log "Configuring Nginx..." "$YELLOW"
if [ -d "/etc/nginx/sites-available" ]; then
    sudo cp config/nginxmy-app-repo.conf /etc/nginx/sites-availablemy-app-repo
    sudo ln -sf /etc/nginx/sites-availablemy-app-repo /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl restart nginx
fi

# Create log files
log "Creating log files..." "$YELLOW"
touch logs/nginx/access.log logs/nginx/error.log
touch logs/api/api.log logs/backend/backend.log logs/app/app.log
chmod 666 logs/nginx/*.log
chmod 644 logs/api/*.log logs/backend/*.log logs/app/*.log

# Set up log rotation
log "Setting up log rotation..." "$YELLOW"
if [ -d "/etc/logrotate.d" ]; then
    sudo cp config/logrotatemy-app-repo /etc/logrotate.d/
fi

log "Setup completed successfully!" "$GREEN"
log "To start the development server, run: ./scripts/start-dev.sh" "$GREEN"