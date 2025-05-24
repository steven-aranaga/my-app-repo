#!/bin/bash
set -e

# Create data and logs directories with proper permissions
mkdir -p /data /logs
chmod 777 /data /logs

# Initialize database if it doesn't exist or is empty
if [ ! -f "/data/data_store.db" ] || [ ! -s "/data/data_store.db" ]; then
    echo "Initializing database..."
    sqlite3 /data/data_store.db <<EOF
CREATE TABLE IF NOT EXISTS data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    identifier TEXT UNIQUE NOT NULL,
    encrypted_data TEXT,
    value REAL DEFAULT 0.0,
    last_updated TIMESTAMP,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
    # Set proper permissions and ownership
    chmod 666 /data/data_store.db
    chown -R 1000:1000 /data /logs
    echo "Database initialized successfully"
fi

# Verify database is accessible
if ! sqlite3 /data/data_store.db "SELECT 1;" >/dev/null 2>&1; then
    echo "Error: Database is not accessible"
    exit 1
fi

cd /usr/src/api
exec api
