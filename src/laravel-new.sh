#!/bin/bash

# Function to display help information
show_help() {
    echo "Created by Bachrul Uluum[@uluumbch] for simplicity"
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Automates Laravel project creation using Laravel Sail inside Docker."
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit."
    echo ""
    echo "Examples:"
    echo "  Run the script and input project details interactively."
    exit 0
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Ask for APP_NAME
read -rp "Enter Laravel project name (default: my-laravel-app): " APP_NAME
APP_NAME="${APP_NAME:-my-laravel-app}"  # Use default if empty

# Ask for SERVICES
read -rp "Enter services to install (default: mysql,redis,meilisearch,mailpit,selenium): " SERVICES
SERVICES="${SERVICES:-mysql,redis,meilisearch,mailpit,selenium}"  # Use default if empty

echo "Creating Laravel project '$APP_NAME' with services: $SERVICES..."
sleep 1  # Small delay for better UX

docker info > /dev/null 2>&1

# Ensure that Docker is running...
if [ $? -ne 0 ]; then
    echo "Docker is not running."
    exit 1
fi

# Run Laravel installer inside Docker
docker run --rm --interactive --tty \
    --pull=always \
    -v "$(pwd)":/opt \
    -w /opt \
    laravelsail/php84-composer:latest \
    bash -c "laravel new $APP_NAME --no-interaction && cd $APP_NAME && php ./artisan sail:install --with=$SERVICES"

if [ -d "$APP_NAME" ]; then
    cd "$APP_NAME"
else
    echo "Laravel installation failed. Check the logs above."
    exit 1
fi

CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""

# Check for sudo or doas
if command -v doas &>/dev/null; then
    SUDO="doas"
elif command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    echo "Neither sudo nor doas is available. Exiting."
    exit 1
fi

# Set correct permissions
if $SUDO -n true 2>/dev/null; then
    $SUDO chown -R $USER: .
    echo -e "${BOLD}Get started with:${NC} cd $APP_NAME && ./vendor/bin/sail up"
else
    echo -e "${BOLD}Please provide your password to set the correct permissions.${NC}"
    echo ""
    $SUDO chown -R $USER: .
    echo ""
    echo -e "${BOLD}Thank you! Start your Laravel project with:${NC} cd $APP_NAME && ./vendor/bin/sail up"
fi
