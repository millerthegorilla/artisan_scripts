# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

These scripts are provided as is, with no support, and the author accepts nil responsibility for any damage or otherwise that using these scripts may cause.  They are alpha, permanently, so proceed with care.

My aim is that I can simply run the script, initial_provision.sh, and this will pull the container images, and then scripts will be called to make the pod, the containers, and add the necessary files to those containers, building a custom container for django along the way.

Because the django container has volume mounts it is necessary to recreate the same directory structure on the host machine.  However, I have made a script to be run as root, that creates the directory structure: create_directories.sh

The directory structure on the host machine is:
for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
for static files there is symlink to django code/static and django code/media inthe following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
    
log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

django code resides at -> /opt/$PROJECT_NAME/

These directories need to be created, and environment files placed inside that can be read by bash or by python-dotenv.  There is a root script create_directories.sh which will make the necessary directories.

When the directories have been made, and before any other scripts are run, the two env files need to be copied to their locations and completed.
The file scripts_env should be named .env and placed in the same directory as the scripts, and completed.
The file settings_env should be named .env and placed in the same directory as settings.py 

