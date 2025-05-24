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

# Change into the repository directory if needed
if [[ "$(pwd)" != *"my-app-repo" ]]; then
    cd /workspace
    echo "Changed to workspace directory: $(pwd)"
fi

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
    logrotate \
    sqlite3 \
    supervisor

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
pip install -r backend/requirements.txt

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
mkdir -p static/css
mkdir -p static/js
mkdir -p static/html

# Set permissions
log "Setting permissions..." "$YELLOW"
chmod 755 data/api data/backend data/frontend
chmod 755 logs logs/nginx logs/api logs/backend logs/app
chmod 755 static static/css static/js static/html

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

# Create empty log files to ensure proper permissions
log "Creating log files with proper permissions..." "$YELLOW"
touch logs/nginx/access.log logs/nginx/error.log
touch logs/api/api.log logs/backend/backend.log logs/app/app.log
chmod 666 logs/nginx/*.log
chmod 644 logs/api/*.log logs/backend/*.log logs/app/*.log

# Initialize database if it doesn't exist
if [ ! -f "data/backend/app.db" ]; then
    log "Initializing database..." "$YELLOW"
    PYTHONPATH=$(pwd) python3 -c "from backend.app.db import init_db; init_db()"
    log "Database initialized" "$GREEN"
fi

# Create static files if they don't exist
if [ ! -f "static/css/styles.css" ]; then
    log "Creating static CSS file..." "$YELLOW"
    echo "body { font-family: Arial, sans-serif; margin: 0; padding: 0; }" > static/css/styles.css
fi

if [ ! -f "static/js/main.js" ]; then
    log "Creating static JS file..." "$YELLOW"
    echo "console.log('My App loaded');" > static/js/main.js
fi

if [ ! -f "static/html/404.html" ]; then
    log "Creating static HTML files..." "$YELLOW"
    echo "<h1>404 - Page Not Found</h1>" > static/html/404.html
    echo "<h1>500 - Server Error</h1>" > static/html/50x.html
fi

log "Setup completed successfully!" "$GREEN"
log "To start the development server, run: ./.openhands/start.sh" "$GREEN"
