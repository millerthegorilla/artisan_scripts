# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

These scripts are provided as is, with no support, and the author accepts nil responsibility for any damage or otherwise that using these scripts may cause.  They are alpha, permanently, so proceed with care.

They are designed to run on a newly installed system, in my case a raspberry pi running Fedora IOT.

Before running the scripts, download them into a directory in your home folder, and git clone the django_artisan code into a directory.  Then, as root, run create_directories.sh.  

When the directories have been made, and before any other scripts are run, the two env files need to be copied to their locations and completed.
The file scripts_env should be named .env and placed in the same directory as the scripts, and completed.
The file settings_env should be named .env and placed in the same directory as settings.py -> /etc/opt/${PROJECT_NAME}/settings

Chmod the .env files as restrictively as possible.

When that is finished, as a standard user, run initial_provision.sh, and this will pull the container images, and then scripts will be called to make the pod, the containers, and add the necessary files to those containers, building a custom container for django along the way.

Because the django container has volume mounts it is necessary to recreate a directory structure on the host machine, that can be referenced by the scripts run_django_cont, and run_swag_cont.  However, I have made a script to be run as root, that creates the directory structure: create_directories.sh

The directory structure on the host machine is:
for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
for static files there is symlink to django code/static and django code/media inthe following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
    
log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

django code resides at -> /opt/$PROJECT_NAME/ which is a symbolic link to the code inside the django_artisan repo, whereever you have cloned that to.
