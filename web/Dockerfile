FROM rust:1.70-slim as builder

# Set environment variables
ENV CARGO_TERM_COLOR=always

# Set up working directory
WORKDIR /app

# Copy Cargo.toml and Cargo.lock
COPY Cargo.toml Cargo.lock* ./

# Create dummy source file to build dependencies
RUN mkdir -p src && echo 'fn main() { println!("Dummy"); }' > src/main.rs

# Build dependencies
RUN cargo build --release

# Remove dummy source files
RUN rm -rf src

# Copy the actual source code
COPY . .

# Build the application
RUN cargo build --release

# Create runtime image
FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy the binary from the builder
COPY --from=builder /app/target/release/web /app/web

# Copy static files and templates
COPY static /app/static
COPY templates /app/templates

# Create necessary directories
RUN mkdir -p /app/logs

# Expose port
EXPOSE 3000

# Run the application
CMD ["/app/web"]

