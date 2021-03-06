#!/usr/bin/env sh

set -e

./manage.py collectstatic -c --no-input

if [ $# -ge 1 ] && [ "$1" = "test" ]; then
  ./manage.py makemigrations --check --dry-run
  ./manage.py check
  exec python -Wa manage.py test
fi

./manage.py migrate
./manage.py remove_stale_contenttypes --include-stale-apps --no-input

if [ $# -ge 1 ] && [ "$1" = "debug" ]; then
  exec python -Wa manage.py runserver 0.0.0.0:8000
else
  ./manage.py check --deploy --fail-level=WARNING
  exec gunicorn
fi
