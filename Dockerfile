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
 \
 # && pecl install grpc \
 # TODO: Remove patch after official fix release \
 # Download gRPC from PECL, patch for PHP 8.5 (zend_exception_get_default removal), then build \
 && pecl download grpc \
 && GRPC_TGZ="$(ls -1 grpc-*.tgz | head -n 1)" \
 && tar -xzf "$GRPC_TGZ" \
 && GRPC_DIR="$(tar -tzf "$GRPC_TGZ" | awk -F/ 'NF>1 {print $1; exit}')" \
 && cd "$GRPC_DIR" \
 && if grep -R "zend_exception_get_default" -n src/php/ext/grpc >/dev/null 2>&1; then \
      find src/php/ext/grpc -type f \( -name '*.c' -o -name '*.h' \) -print0 \
        | xargs -0 sed -E -i 's/zend_exception_get_default\([^)]*\)/zend_ce_exception/g'; \
    fi \
 && phpize \
 && ./configure \
 && make \
 && make install \
 && cd / \
 && docker-php-ext-enable grpc \
 \
 && apt-get purge -y autoconf build-essential pkg-config libssl-dev zlib1g-dev git \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* /tmp/pear "$GRPC_DIR" "$GRPC_TGZ"
