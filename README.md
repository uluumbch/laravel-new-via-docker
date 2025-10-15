# laravel-new-via-docker
A simple script for running laravel installer via docker without need to install php in local computer

**Requirements**: Docker must be installed and running on your system.

## Usage

### Interactive mode
1. run
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uluumbch/laravel-new-via-docker/HEAD/src/laravel-new.sh)"
   ```
2. Answer the questions
3. 🚀Start develop your laravel project!

### Non-interactive usage (CI)

For CI/CD pipelines or automated environments, you can set environment variables to skip interactive prompts:

```bash
APP_NAME=my-app SERVICES=mysql,redis AUTO_ACCEPT=1 bash ./src/laravel-new.sh
```

Or with the remote script:

```bash
APP_NAME=my-app SERVICES=mysql,redis AUTO_ACCEPT=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uluumbch/laravel-new-via-docker/HEAD/src/laravel-new.sh)"
```

**Environment variables:**
- `APP_NAME`: Laravel project name (default: `my-laravel-app`)
- `SERVICES`: Comma-separated list of services (default: `mysql,redis,meilisearch,mailpit,selenium`)
- `AUTO_ACCEPT=1`: Accept Laravel installer defaults non-interactively (Starter kit: None; Testing: Pest; DB: MySQL; Migrations: No)

**Note:** The script automatically detects TTY availability and allocates `--tty` to Docker only when appropriate, ensuring compatibility with CI environments.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each release.

![Demo Image](art/demo.png)