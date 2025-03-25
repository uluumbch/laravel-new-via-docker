#!/bin/bash
# Keep the container running
exec "$@" || tail -f /dev/null