#!/bin/bash

# Function to display help information
show_help() {
    echo "Created by Bachrul Uluum[@uluumbch] for simplicity"
    echo "Usage: $(basename "$0") [APP_NAME] [--with=services]"
    echo ""
    echo "Automates Laravel project creation using Laravel Sail inside Docker."
    echo ""
    echo "Arguments:"
    echo "  APP_NAME        Optional. The name of the Laravel application to create."
    echo "  --with=SERVICES Optional. A comma-separated list of services to install with Sail."
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit."
    echo ""
    echo "Examples:"
    echo "  ./$(basename "$0") my-laravel-app                     # Create Laravel project with default services."
    echo "  ./$(basename "$0") my-laravel-app --with=mysql,redis  # Create Laravel project with only MySQL and Redis."
    exit 0
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Default values
APP_NAME="my-laravel-app"
SERVICES="mysql,redis,meilisearch,mailpit,selenium"  # Default services

# Read arguments
for arg in "$@"; do
    case $arg in
        --with=*) SERVICES="${arg#*=}"; shift ;;
        *) APP_NAME="$arg" ;;
    esac
done

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
LIGHT_CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""

if command -v doas &>/dev/null; then
    SUDO="doas"
elif command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    echo "Neither sudo nor doas is available. Exiting."
    exit 1
fi

if $SUDO -n true 2>/dev/null; then
    $SUDO chown -R $USER: .
    echo -e "${BOLD}Get started with:${NC} cd $APP_NAME && ./vendor/bin/sail up"
else
    echo -e "${BOLD}Please provide your password so we can make some final adjustments to your application's permissions.${NC}"
    echo ""
    $SUDO chown -R $USER: .
    echo ""
    echo -e "${BOLD}Thank you! We hope you build something incredible. Dive in with:${NC} cd $APP_NAME && ./vendor/bin/sail up"
fi
