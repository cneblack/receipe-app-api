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
    -makemigrations  )
        echo "$0: ${1#-}"
        set -- python manage.py makemigrations core
	;;
    -migrate  )
        echo "$0: ${1#-}"
        set -- python manage showmigrations
        set -- python manage.py migrate
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
        # "$0" -collectstatic
        # "$0" -makemigrations
        # "$0" -migrate
        # "$0" -createcachetable
        # "$0" -sync_email_templates
        # "$0" -sync_user_pwd_selfcare
        # set -- "$0" -uwsgi
        "$0" -wait_for_db
        "$0" -makemigrations
        "$0" -migrate
        "$0" -runserver
        ;;

esac

exec "$@"
