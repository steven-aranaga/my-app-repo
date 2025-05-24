FROM rust:slim-bookworm AS builder
WORKDIR /usr/src/api
COPY api/Cargo.toml ./
COPY api/Cargo.lock ./
COPY api/src/ src/
# Install sqlx-cli and prepare offline query data
RUN cargo install sqlx-cli --no-default-features --features rustls,sqlite

# Install sqlite3 for database initialization
RUN apt-get update && \
    apt-get install -y --no-install-recommends sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Copy .env file for build-time environment variables
COPY .env .env

# Make sure SQLite is installed
RUN apt-get update && \
    apt-get install -y --no-install-recommends sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Set the DATABASE_URL for any subsequent steps
ENV DATABASE_URL=sqlite:////data/data_store.db?mode=rwc

# Initialize the database file
RUN mkdir -p /data \
    && touch /data/data_store.db \
    && chmod 666 /data/data_store.db \
    && sqlite3 /data/data_store.db "CREATE TABLE IF NOT EXISTS data (id TEXT PRIMARY KEY, value REAL, last_updated TEXT);"

# Generate the query cache
RUN cargo sqlx prepare --workspace

# Build with offline mode enabled
ENV SQLX_OFFLINE=true
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/bin/
COPY --from=builder /usr/src/api/target/release/api /usr/local/bin/api
COPY api/entrypoint.sh /usr/local/bin/
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/entrypoint.sh

# Create data directory and set permissions
RUN mkdir -p /data && chmod 777 /data

COPY api/Cargo.toml api/Cargo.lock /usr/src/api/
COPY api/src/ /usr/src/api/src/
WORKDIR /usr/src/api

EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
