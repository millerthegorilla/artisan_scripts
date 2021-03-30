#!/bin/bash

podman container exists $DJANGO_CONT_NAME;
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container $DJANGO_CONT_NAME...
	podman start $DJANGO_CONT_NAME;
else
	echo $DJANGO_CONT_NAME DOESN\'T EXIST, creating....;
	podman run -d -it --pod $POD_NAME --name $DJANGO_CONT_NAME -v /opt/$DJANGO_PROJECT_NAME:/opt/$DJANGO_PROJECT_NAME:Z -v /etc/opt/$DJANGO_PROJECT_NAME:/etc/opt/$DJANGO_PROJECT_NAME:Z -v /var/home/pod_server/$DJANGO_PROJECT_NAME/logs:/var/logs/$DJANGO_PROJECT_NAME:Z $DJANGO_IMAGE
fi

