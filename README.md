# laravel-new-via-docker
A simple script for running laravel installer via docker without need to install php in local computer


## Download the script
1. run `curl -s "repo" -o laravel-new.sh`
2. change permission `sudo chmod +x laravel-new.sh`
3. run with `laravel-new.sh my-new-app`


get help with `-h` or `--help` argument

```
Usage: laravel-new [APP_NAME]

Automates Laravel project creation using Laravel Sail inside Docker.

Arguments:
  APP_NAME   Optional. The name of the Laravel application to create.

Options:
  -h, --help  Show this help message and exit.

Examples:
  ./laravel-new my-laravel-app   # Create a Laravel project named 'my-laravel-app'
  ./laravel-new                 # Create a Laravel project with the default name 'my-laravel-app'
```
