# laravel-new-via-docker
A simple script for running laravel installer via docker without need to install php in local computer


## Download the script
1. run
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uluumbch/laravel-new-via-docker/HEAD/src/laravel-new.sh)"
   ```
3. change permission
   ```
   sudo chmod +x laravel-new.sh
   ```
5. run with `laravel-new.sh my-new-app`


get help with `-h` or `--help` argument

```
Created by Bachrul Uluum[@uluumbch] for simplicity
Usage: laravel-new [APP_NAME] [--with=services]

Automates Laravel project creation using Laravel Sail inside Docker.

Arguments:
  APP_NAME        Optional. The name of the Laravel application to create.
  --with=SERVICES Optional. A comma-separated list of services to install with Sail.

Options:
  -h, --help      Show this help message and exit.

Examples:
  ./laravel-new my-laravel-app                     # Create Laravel project with default services.
  ./laravel-new my-laravel-app --with=mysql,redis  # Create Laravel project with only MySQL and Redis.
```
