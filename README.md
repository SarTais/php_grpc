# PHP gRPC Docker Image

This repository hosts a Docker image that includes the pre-built [gRPC PHP extension](https://grpc.io/docs/languages/php/) for faster PHP builds. Instead of compiling the gRPC extension during your image build, you can simply copy the pre-built binaries and configuration from this image.

> **Note:** This setup currently only contains gRPC for Debian-based PHP images.
## Supported PHP Versions

- PHP 8.3
- PHP 8.4

## Multi-Architecture (buildx) Support

This project provides multi-architecture Docker images (linux/amd64 and linux/arm64).  
To build the images locally using Docker Buildx, ensure buildx is enabled and a multi-arch builder is created.

### Enabling buildx

```bash
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap
```

You should see output indicating that both amd64 and arm64 platforms are supported.

## How to Use

In your Dockerfile, use the multi-stage build feature to copy the pre-built gRPC extension and its configuration into your PHP image. For PHP 8.3, for example, you can add the following lines:

```dockerfile
# Copy all PHP extension files (including grpc.so) from our pre-built image
COPY --from=ghcr.io/sartais/php_grpc:8.3 /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# Copy the gRPC PHP configuration file
COPY --from=ghcr.io/sartais/php_grpc:8.3 /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini

# Enable the gRPC PHP extension
RUN docker-php-ext-enable grpc

# Install protobuf via PECL and enable it
RUN pecl install protobuf && docker-php-ext-enable protobuf

# For a smaller image layer, install protobuf and enable both grpc and protobuf in one command
RUN pecl install protobuf && docker-php-ext-enable grpc protobuf
```

## Example of grpc and protobuf for php client
```dockerfile
COPY --from=ghcr.io/sartais/php_grpc:8.3 /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=ghcr.io/sartais/php_grpc:8.3 /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini

RUN pecl install protobuf && docker-php-ext-enable grpc protobuf
```

# License

This project is licensed under the MIT License. See the LICENSE file for details.
