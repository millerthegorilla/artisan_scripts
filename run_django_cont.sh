#!/bin/bash

podman container exists $DJANGO_NAME;
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container $DJANGO_NAME...
	podman start $DJANGO_NAME;
else
	echo $DJANGO_NAME DOESN\'T EXIST, creating....;
	podman run -d -it --pod $POD_NAME --name $DJANGO_NAME -v /opt/$DJANGO_PROJECT_NAME:/opt/$DJANGO_PROJECT_NAME:Z -v /etc/opt/$DJANGO_PROJECT_NAME:/etc/opt/$DJANGO_PROJECT_NAME:Z -v $HOME/$DJANGO_PROJECT_NAME/logs:/var/log/$DJANGO_PROJECT_NAME:Z $DJANGO_IMAGE_NAME
fi

