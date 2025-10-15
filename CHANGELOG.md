# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - YYYY-MM-DD

### Features
- **Non-interactive mode via AUTO_ACCEPT=1**: Accept Laravel installer defaults automatically (Starter kit: None; Testing: Pest; DB: MySQL; Migrations: No) for CI/CD environments.
- **Environment variable support**: Script reads `APP_NAME` and `SERVICES` from environment variables; prompts only if missing, enabling fully automated project creation.
- **Conditional Docker TTY allocation**: Improved CI compatibility by conditionally allocating TTY only when a TTY is attached, preventing CI pipeline failures.

### Fixes
- **Safer devcontainer.json update**: Now uses `jq` (with `jq -> tmp -> mv` pattern) for JSON manipulation when available; falls back to `sed` when parsing JSONC files.
- **Unescaped ${containerWorkspaceFolder}**: Fixed variable expansion in devcontainer.json postCreateCommand to ensure correct path resolution in VS Code Dev Containers.

### CI
- **E2E GitHub Actions workflow**: Added end-to-end testing workflow that runs the installer non-interactively and asserts generated files, ensuring the installation process works correctly in CI environments.

## [0.2.4] - Previous Release

See git history for changes in earlier versions.
