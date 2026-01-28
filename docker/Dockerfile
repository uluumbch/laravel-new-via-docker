FROM debian:latest

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Debug the version of the image
RUN cat /etc/debian_version && cat /etc/os-release

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Add Sury PHP repository (alternative to PPA for Debian)
RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

# Install PHP 8.4 and required extensions
RUN apt-get install -y \
    php8.4 \
    php8.4-cli \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-curl \
    php8.4-zip \
    php8.4-bcmath \
    php8.4-intl \
    php8.4-pdo \
    php8.4-mysql \
    php8.4-gd \
    php8.4-opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Verify installation
RUN php -v && composer --version

RUN git clone https://github.com/laravel/installer laravel-installer && \
    cd laravel-installer && \
    composer install && \
    ln -s /laravel-installer/bin/laravel /usr/bin/laravel && \
    chmod +x /usr/bin/laravel

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php", "-a"]
