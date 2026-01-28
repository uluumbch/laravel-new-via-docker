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

# Ask for APP_NAME only if not provided via env
if [ -z "${APP_NAME:-}" ]; then
    read -rp "Enter Laravel project name (default: my-laravel-app): " APP_NAME
fi
APP_NAME="${APP_NAME:-my-laravel-app}"  # Use default if empty

# Ask for SERVICES only if not provided via env
if [ -z "${SERVICES:-}" ]; then
    cat <<'EOF'

Available services:
  - mariadb
  - meilisearch
  - memcached
  - minio
  - mongodb
  - mysql
  - pgsql
  - rabbitmq
  - redis
  - rustfs
  - selenium
  - soketi
  - typesense
  - valkey

EOF

    read -rp "Enter services to install (default: mysql,redis,mailpit): " SERVICES
fi
SERVICES="${SERVICES:-mysql,redis,mailpit}"  # Use default if empty

echo "Creating Laravel project '$APP_NAME' with services: $SERVICES..."
sleep 1  # Small delay for better UX

docker info > /dev/null 2>&1

# Ensure that Docker is running...
if [ $? -ne 0 ]; then
    echo "Docker is not running."
    exit 1
fi

# Allocate TTY only if we have one (important for CI)
DOCKER_TTY=""
if [ -t 1 ]; then
    DOCKER_TTY="--tty"
fi

# Build the installer command; allow AUTO_ACCEPT to auto-accept defaults
INSTALL_CMD="laravel new \"$APP_NAME\""
if [ -n "${AUTO_ACCEPT:-}" ]; then
    INSTALL_CMD="yes '' | $INSTALL_CMD"
fi

# Compose full inner command
INNER_CMD="$INSTALL_CMD && cd \"$APP_NAME\" && php ./artisan sail:install --with=$SERVICES --devcontainer"

# Run Laravel installer inside Docker
docker run --rm --interactive $DOCKER_TTY \
    --pull=always \
    -v "$(pwd)":/opt \
    -w /opt \
    ghcr.io/uluumbch/laravel-new-via-docker:latest \
    bash -lc "$INNER_CMD"

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

    # Update devcontainer.json from stub
    if [ -f ".devcontainer/devcontainer.json" ]; then
        # Determine the correct compose file (Sail might generate docker-compose.yml or compose.yaml)
        COMPOSE_FILE="../docker-compose.yml"
        if [ -f "compose.yaml" ]; then
            COMPOSE_FILE="../compose.yaml"
        fi

        # Overwrite devcontainer.json with stub content
        # Note: We use the embedded content to ensure portability (e.g. curl | bash)
        cat > .devcontainer/devcontainer.json << EOF
// https://aka.ms/devcontainer.json
{
    "name": "Laravel app",
    "dockerComposeFile": ["$COMPOSE_FILE"],
    "service": "laravel.test",
    "workspaceFolder": "/var/www/html",
    "customizations": {
        "vscode": {
            "extensions": [
                "laravel.vscode-laravel",
                "mikestead.dotenv",
                "amiralizadeh9480.laravel-extra-intellisense",
                "onecentlin.laravel5-snippets",
                "onecentlin.laravel-blade",
                "laravel.vscode-laravel",
                "bmewburn.vscode-intelephense-client",
                "shufo.vscode-blade-formatter"
            ],
            "settings": {}
        }
    },
    "remoteUser": "sail",
    "postCreateCommand": "chown -R 1000:1000 /var/www/html 2>/dev/null || true && cp \${containerWorkspaceFolder}/.devcontainer/alias.bashrc ~/.bash_aliases"
    // "forwardPorts": [],
    // "runServices": [],
    // "shutdownAction": "none",
}
EOF
        echo "Updated .devcontainer/devcontainer.json from stub"
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