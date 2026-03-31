ARG PHP_TAG

FROM php:${PHP_TAG} AS grpc

# Install build dependencies needed for compiling the grpc extension
RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    git \
 && pecl channel-update pecl.php.net \
 && pecl install grpc \
 && docker-php-ext-enable grpc \
 \
 && apt-get purge -y autoconf build-essential pkg-config libssl-dev zlib1g-dev git \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* /tmp/pear "$GRPC_DIR" "$GRPC_TGZ"
