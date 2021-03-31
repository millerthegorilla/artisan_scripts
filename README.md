# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

My aim is that I can simply run the script, initial_provision.sh, and this will pull the container images, and then scripts will be called to make the pod, the containers, and add the necessary files to those containers, building a custom container for django along the way.

Because the django container has volume mounts it is necessary to recreate the same directory structure on the host machine.

The directory structure on the host machine is:
for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
for static files there is symlink to django code/static and django code/media inthe following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
    
log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

django code resides at -> /opt/$PROJECT_NAME/

These directories need to be created, and environment files placed inside that can be read by bash or by python-dotenv
