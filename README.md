# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

You will need the following created and ready...
* a duckdns account, with your token and subdomain address at the ready
* a gmail account that sends email
* an app password for that account (you need to set up 2 step verification... https://support.google.com/accounts/answer/185833?hl=en")
* google recaptcha public key   https://developers.google.com/recaptcha/intro
* google recaptcha private key

These scripts are provided as is, with no support, and the author accepts nil responsibility for any damage or otherwise that using these scripts may cause.  They are alpha, permanently, so proceed with care.

They are designed to run on a newly installed system, in my case a raspberry pi running Fedora IOT.

Before running the scripts, download them into a directory in your home folder, and git clone the django_artisan code into a directory.

Then, as root, run create_directories.sh.  This will create the directories necessary for the volume mounts from the containers which use them.

When the directories have been made, the create_directories script edits and reloads sysctl to lower the available port numbers to 80.  Be aware that this can be a ***SECURITY ISSUE***.  As long as you manage your firewall sensibly it should be ok.

When create_directories is finished, as a standard user, run initial_provision.sh, and this will pull the container images, and build a custom container for django.  This process can take a while.

The script initial_provision.sh calls the script create_all.sh, which will do the rest of the work.  It calls the script get_variables.sh to read input to complete the settings variable to run your project.

If at any point the scripts fail or you break out of them, you can run the script cleanup.sh to remove the containers and to reset the script environment to the beginning.
Assuming you answer no to the questions about images, code, and logs, you only need to run create_all.sh to begin the process of installation again.
To clean up completely, run the create_all.sh, answer yes to code removal, and to image removal, and to log removal, and then, as root, delete the directories listed at the end of running the cleanup.sh script.

The directory structure on the host machine is:

for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
for static files there is symlink to django code/static and django code/media inthe following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
    
log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

django code resides at -> /opt/$PROJECT_NAME/ which is a symbolic link to the code inside the django_artisan repo, whereever you have cloned that to.
