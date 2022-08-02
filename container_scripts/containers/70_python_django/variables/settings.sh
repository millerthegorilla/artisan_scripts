XDESK=XDG_RUNTIME_DIR="/run/user/1001" DBUS_SESSION_BUS_ADDRESS="unix:path=/bus"
BASE_DIR=/opt/ceramic_isles_dev/
STATIC_BASE_ROOT=/opt/ceramic_isles_dev/
MEDIA_BASE_ROOT=/opt/ceramic_isles_dev/
HOST_LOG_DIR=/home/dev/ceramic_isles_dev/logs
DJANGO_CONT_LOG_DIR=/var/log/ceramic_isles_dev/
DJANGO_HOST_STATIC_VOL=/etc/opt/ceramic_isles_dev/static_files/
DJANGO_CONT_STATIC_VOL=/etc/opt/ceramic_isles_dev/static_files/
DJANGO_HOST_MEDIA_VOL=/etc/opt/ceramic_isles_dev/media_files/
DJANGO_CONT_MEDIA_VOL=/etc/opt/ceramic_isles_dev/media_files/
DJANGO_SECRET_KEY=iT\5zRB&N1b<ECw;_$N+P1d0=qGkT*Wm7VJx9;ZRb\j9f$Y&0]
DJANGO_CONT_NAME=django_cont
DJANGO_IMAGE=python:ceramic_isles_dev_debug
DOCKERFILE_APP_NAMES="RUN ; mkdir -p /opt/ceramic_isles_dev/django_artisan; ; mkdir -p /opt/ceramic_isles_dev/django_bs_carousel; ; mkdir -p /opt/ceramic_isles_dev/django_forum; ; mkdir -p /opt/ceramic_isles_dev/django_messages; ; mkdir -p /opt/ceramic_isles_dev/django_profile; ; mkdir -p /opt/ceramic_isles_dev/django_users; ; mkdir -p /opt/ceramic_isles_dev/safe_imagefield; "
MOUNT_SRC_CODE=TRUE
MOUNT_GIT=FALSE
SRC_CODE_PATH=/home/dev/src/ceramic_isles_app_srcs/
