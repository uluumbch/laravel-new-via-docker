#!/bin/bash

# A function to show help information
show_help() {
    echo "Usage: $(basename "$0")"
    echo "This script creates a new Laravel project using Docker and Laravel Sail."
    echo "more info at: https://github.dev/uluumbch/laravel-new-via-docker"
    echo
    echo "It will prompt for the project name and the services to install."
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message and exit."
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
    ghcr.io/uluumbch/laravel-new-via-docker:latest \
    bash -c "laravel new $APP_NAME && cd $APP_NAME && php ./artisan sail:install --with=$SERVICES --devcontainer"

if [ -d "$APP_NAME" ]; then
    cd "$APP_NAME" || exit

    echo "Setting correct permissions for project files..."
    # Check for sudo or doas
    if command -v doas &>/dev/null; then
        SUDO_CMD="doas"
    elif command -v sudo &>/dev/null; then
        SUDO_CMD="sudo"
    else
        echo "Neither sudo nor doas is available. Cannot set file ownership. Subsequent operations might fail."
        SUDO_CMD="" # Ensure SUDO_CMD is defined to avoid unbound variable error
    fi

    if [ -n "$SUDO_CMD" ]; then # Only proceed if sudo or doas is found
        if $SUDO_CMD -n true 2>/dev/null; then # Check if passwordless sudo is possible
            $SUDO_CMD chown -R "$USER:" .
        else
            echo "Please provide your password to set the correct permissions for the project files."
            $SUDO_CMD chown -R "$USER:" .
        fi
        echo "File permissions updated."
    fi

else
    echo "Laravel installation failed. Check the logs above."
    exit 1
fi

# Create alias.bashrc in .devcontainer folder
if [ -d ".devcontainer" ]; then
    cat > .devcontainer/alias.bashrc << 'EOL'
#!/bin/bash

# PHP aliases
alias pa="php artisan"
alias pint="vendor/bin/pint"

# Node/NPM aliases
alias npd='npm run dev'
EOL

    echo "Created .devcontainer/alias.bashrc with aliases"

    # Update devcontainer.json postCreateCommand
    if [ -f ".devcontainer/devcontainer.json" ]; then
        # Use jq if available, as it's safer for JSON manipulation
        if command -v jq &>/dev/null; then
            jq '.postCreateCommand = "chown -R 1000:1000 /var/www/html 2>/dev/null || true && cp \${containerWorkspaceFolder}/.devcontainer/alias.bashrc ~/.bash_aliases"' .devcontainer/devcontainer.json > .devcontainer/devcontainer.json.tmp && \
            mv .devcontainer/devcontainer.json.tmp .devcontainer/devcontainer.json
        else
            # Fallback to a more robust sed command if jq isn't available
            # This finds the postCreateCommand line and replaces its value, preserving a potential trailing comma.
            sed -i.bak 's#^\(\s*"postCreateCommand":\s*"\)[^"]*"\(\s*,*\s*\)$#\1chown -R 1000:1000 /var/www/html 2>/dev/null || true \&\& cp \${containerWorkspaceFolder}/.devcontainer/alias.bashrc ~/.bash_aliases"\2#' .devcontainer/devcontainer.json
            rm -f .devcontainer/devcontainer.json.bak
        fi
        echo "Updated .devcontainer/devcontainer.json postCreateCommand"
    else
        echo "Warning: .devcontainer/devcontainer.json not found. Cannot update postCreateCommand."
    fi
else
    echo "Warning: .devcontainer directory not found. Cannot create alias.bashrc or update devcontainer.json."
fi

CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}Get started with:${NC} cd $APP_NAME && ./vendor/bin/sail up"