FROM rust:slim-bookworm AS builder

WORKDIR /usr/web

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy source code
COPY web/Cargo.toml web/Cargo.lock ./
COPY web/src ./src
COPY web/content ./content
COPY web/static ./static
COPY web/templates ./templates
# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /usr/web

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built binary and assets
COPY --from=builder /usr/web/target/releasemy-app-repo-web .
COPY --from=builder /usr/web/content ./content
COPY --from=builder /usr/web/static ./static
COPY --from=builder /usr/web/templates ./templates

# Create non-root user
RUN useradd -m -u 1000 web
RUN chown -R web:web /usr/web

USER web

EXPOSE 8080

CMD [".my-app-repo-web"] 