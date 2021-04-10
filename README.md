# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

### requirements...

You will need the following created and ready...
* a linux system running a reasonably recently updated podman (tested >=2.2)
* a duckdns account, with your token and subdomain address at the ready
* a gmail account that sends email
* an app password for that account (you need to set up 2 step verification... https://support.google.com/accounts/answer/185833?hl=en")
* google recaptcha public key   https://developers.google.com/recaptcha/intro
* google recaptcha private key
* the path to the directory where you have cloned django_artisan

### disclaimer...

These scripts are provided as is, with no support, and the author accepts nil responsibility for any damage or otherwise that using these scripts may cause.  They are alpha, permanently, so proceed with care.  The scripts have only been tested on machines running Fedora CoreOs, ie Silverblue and Fedora IOT.

I have tested them on a newly installed system, in my case a raspberry pi running Fedora IOT.

### Swag - nginx container

The scripts set up containers and environment necessary to run django_artisan as an SSL enabled site.  The SSL service is provided by the LinuxServer team's SWAG image (https://hub.docker.com/r/linuxserver/swag) SWAG stands for Secure Application Gateway, apparently.  Inside the container, letsencrypt certbot runs to ggenerate SSL certificates, and is configured in this instance to provide SSL certs for a duckdns subdomain and for a single extra TLD domain.  I use duckdns subdomain to point at the nginx container, and then use a TLD domain from Namesco, to act as a redirect to the duckdns subdomain.  The site then runs on my home server, and the only cost I have is renewal of the TLD domain name, as it then gets listed in Google search etc, where the duckdns subdomain is ignored.

### what to do...

Before running the scripts, download them into a directory in your home folder, and git clone the django_artisan code into a directory.

Then, as root, run create_directories.sh.  This will create the directories necessary for the volume mounts from the containers which use them.

When the directories have been made, the create_directories script edits and reloads sysctl to lower the available port numbers to 80.  Be aware that this can be a ***SECURITY ISSUE***.  As long as you manage your firewall sensibly it should be ok.

When create_directories is finished, as a standard user, run initial_provision.sh, and this will pull the container images, and build a custom container for django.  This process can take a while.

The script initial_provision.sh calls the script create_all.sh, which will do the rest of the work.  It calls the script get_variables.sh to read input to complete the settings variable to run your project.

If at any point the scripts fail or you break out of them, you can run the script cleanup.sh to remove the containers and to reset the script environment to the beginning.
Assuming you answer no to the questions about images, code, and logs, you only need to run create_all.sh to begin the process of installation again.
To clean up completely, run the create_all.sh, answer yes to code removal, and to image removal, and to log removal, and then, as root, delete the directories listed at the end of running the cleanup.sh script.

### directory structure 

The directory structure on the host machine is:

* for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
* for static files there is symlink to django code/static and django code/media inthe following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
    
* log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

* django code resides at -> /opt/$PROJECT_NAME/ which is a symbolic link to the code inside the django_artisan repo, wherever you have cloned that to.  So clone django_artisan to any directory you wish, and then the script will ask you for project_name and for the path to your code, and then symlink from opt to the django_artisan code directory.

### firewall and router...

When the scripts have finished running, you will need to open your firewall ports 80 and 443, and make sure that your router firewall is forwarding those two ports to your machine's ip address.

### server reload...

If you make any changes to the code base, and need to reload the server, you can run the script 'reload.sh'.  This will kill the gunicorn process and run it from fresh and then start and stop the swag container to reload nginx.

### customising scripts

If you want to add a container, or customise an existing container, you can either edit initial_provision.sh to install a new image, or customise/add a script to the scripts directory.
The script create_all.sh shells out to a bunch of scripts in that scripts directory.  In each of these scripts are a bunch of podman commands to bring up a container, and to customise it in some way.
The script get_variables.sh reads user input to get environment variables.  This then uses the envsubst command to complete a ./templates/env_files/scripts_env and ./templates/env_files/settings_env.
The scripts_env provides environment variables to the scripts, and the settings_env is copied to the directory /etc/opt/$PROJECT_NAME/settings to be read as and when by settings.py.
If you want to change any image tag then you will need to do so in the script ./initial_provision.sh and also the file ./templates/env_files/scripts_env.

### customising django_artisan

You can customise the settings of django_artisan, by editing the file settings.py in the settings directory.  Make certain that you don't delete and of the environment variables eg anywhere that os.getenv is used, as these are completed by the script get_variables.sh.   Places to customise are the text that is displayed in the header and in the about page - NAVBAR_SPIEL and ABOUT_US_SPIEL or the SITE_LOGO for example.

Have fun!
