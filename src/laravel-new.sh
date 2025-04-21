#!/bin/bash

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
    cd "$APP_NAME"
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

    echo "Created .devcontainer/alias.bashrc with  aliases"

    # Update devcontainer.json postCreateCommand
    if [ -f ".devcontainer/devcontainer.json" ]; then
        # Use jq if available
        if command -v jq &>/dev/null; then
            jq '. += {"postCreateCommand": "chown -R 1000:1000 /var/www/html 2>/dev/null || true && cp ${containerWorkspaceFolder}/.devcontainer/alias.bashrc ~/.bash_aliases"}' .devcontainer/devcontainer.json > .devcontainer/devcontainer.json.tmp && \
            mv .devcontainer/devcontainer.json.tmp .devcontainer/devcontainer.json
        else
            # Fallback to sed if jq isn't available
            sed -i.bak 's#"postCreateCommand": "chown -R 1000:1000 /var/www/html 2>/dev/null || true"#"postCreateCommand": "chown -R 1000:1000 /var/www/html 2>/dev/null || true && cp ${containerWorkspaceFolder}/.devcontainer/alias.bashrc ~/.bash_aliases"#g' .devcontainer/devcontainer.json
            rm -f .devcontainer/devcontainer.json.bak
        fi
        echo "Updated .devcontainer/devcontainer.json postCreateCommand"
    fi
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
