FROM python:slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    CC=gcc \
    CXX=g++

# install a C compiler, Python headers, CMake, and other libs needed for native builds
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      python3-dev \
      cmake \
      pkg-config \
      libssl-dev \
      sqlite3 \
      sudo \
      libtool-bin \
      automake \
      git \
      libgmp-dev \
      python3-pip \
      python3-dev \
      libffi-dev \
 && rm -rf /var/lib/apt/lists/*

# Install OpenSSL development libraries for cryptography
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir \
    cryptography \
    pyOpenSSL \
    -r requirements.txt

# Copy Python files from backend directory
COPY backend/*.py .
COPY backend/data_handlers/ data_handlers/
COPY scripts/setup-docker.sh .

# Create appuser with specific UID/GID matching host user
RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -m -s /bin/bash appuser && \
    mkdir -p /data && \
    chown -R appuser:appgroup /data && \
    chmod 775 /data && \
    echo "appuser ALL=(ALL) NOPASSWD: /bin/chmod, /bin/chown" >> /etc/sudoers

# Set proper permissions for application files
RUN chown -R appuser:appgroup /app && \
    chmod 755 /app && \
    find /app -type f -exec chmod 644 {} \; && \
    find /app -type d -exec chmod 755 {} \; && \
    chmod +x /app/setup-docker.sh

# Set environment variables for permission control
ENV PYTHONPATH=/app \
    UMASK=0002 \
    USER=appuser \
    GROUP=appgroup

VOLUME ["/data"]
USER appuser
CMD ["/app/setup-docker.sh"]
