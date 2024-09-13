#!/bin/sh
set -ue
SYSTEMD_PREFIX_NAME=django


case "${1:-}" in

    -runserver)
        echo "$0: ${1#-}"
        set -- python manage.py runserver 0.0.0.0:8000
	;;
    -wait_for_db )
        echo "$0: ${1#-}"
        set -- python manage.py wait_for_db 
	;;
    -tests )
        echo "$0: ${1#-}"
        set -- python manage.py test 
	;;
    -makemigrations  )
        echo "$0: ${1#-}"
        set -- python manage.py makemigrations core
	;;
    -collectstatic  )
        echo "$0: ${1#-}"
        set -- python manage.py collectstatic --noinput
    ;;
    -migrate  )
        echo "$0: ${1#-}"
        set -- python manage.py showmigrations
        set -- python manage.py migrate
	;;
    -shell)
        echo "$0: ${1#-}"
        set -- python manage.py shell
        ;;

    -bash)
        echo "$0: ${1#-}"
        set -- /bin/bash
        ;;
    -uwsgi)
        echo "$0: ${1#-}"
        set -- uwsgi \
                     --workers 16 --master --no-orphans --vacuum \
                     --master-fifo /tmp/uwsgi-master-fifo \
                     --py-autoreload 1 \
                     --socket 0.0.0.0:4080 \
                     --module selfCare.wsgi \
                     --buffer-size 32768 \
                     --harakiri 900 --harakiri-verbose
        ;;

    -start)
        echo "$0: ${1#-}"
        "$0" -wait_for_db
        "$0" -collectstatic
        "$0" -makemigrations
        "$0" -migrate
        "$0" -runserver
        ;;

esac

exec "$@"
