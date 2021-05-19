# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

### license
As poor as these scripts are, and keeping in mind I accept no responsibility for any errors or headaches they may create, they are released, like Django Artisan, under an MIT license.

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

### Swag Secure Web Application Gateway - nginx container

The scripts set up containers and environment necessary to run django_artisan as an SSL enabled site.  The SSL service is provided by the LinuxServer team's SWAG image (https://hub.docker.com/r/linuxserver/swag) SWAG stands for Secure Application Gateway, apparently.  Inside the container, letsencrypt certbot runs to ggenerate SSL certificates, and is configured in this instance to provide SSL certs for a duckdns subdomain and for a single extra TLD domain.  I use duckdns subdomain to point at the nginx container, and then use a TLD domain from Namesco, to act as a redirect to the duckdns subdomain.  The site then runs on my home server, and the only cost I have is renewal of the TLD domain name, as it then gets listed in Google search etc, where the duckdns subdomain is ignored.

### what to do...

Before running the scripts, download them into a directory in your home folder, and git clone the django_artisan code into a directory.

Then run the script artisan_run.sh which takes one command to direct it to the correct scripts.
The commands are 'create', 'clean', 'replace', 'reload' or 'help'.

eg   $ ./artisan_run create

The create verb runs the script create_directories.sh and then checks the podman images, and downloads them and/or builds them as necessary, in the script initial_provision.sh.  Then the script 'create_all.sh' is called which creates and provisions the containers.  Depending on your options, either a development setup will be created, running manage.py on port 8000, or a production setup will be created, opening ports 443 and 80.  In any case the create_directories.sh script will edit and reload sysctl to lower the available port numbers to 80.  Be aware that this can be a ***SECURITY ISSUE***.  As long as you manage your firewall sensibly it should be ok.

If at any point the scripts fail or you break out of them, you can run the script cleanup.sh to remove the containers and to reset the script environment to the beginning.

To clean up completely, run the cleanup.sh, answer yes to code removal, and to image removal, and to log removal.

When the django_artisan code is installed, the files 'manage.py' and 'wsgi.py' are not present.  They are created by running these artisan_scripts.  If you lose the 'manage.py' and/or 'wsgi.py' files then you can recreate them by running artisan_run with the replace verb.

In the case of a production setup, you can reload the gunicorn instance, by using artisan_run with the reload verb.  This simply uses podman exec to shell into the django container, and runs supervisorctl reload. 

### super user

From time to time the scripts will prompt for your superuser (sudo) account name, and you will have to enter your password twice, once to shell into the superuser account, and the second time to run the sudo command.

### options

There is a file in the root directory called 'options'.  It currently only has one line which is the command to run a terminal.  I am using Gnome 3, so the TERMINAL_CMD is set to 'gnome-terminal --'.   If you are using xterm, then you will want to edit the file and change TERMINAL_CMD to 'xterm -e' etc etc.
The TERMINAL_CMD is used to spawn a terminal in the case of using a development install.  In this case when you start your machine, or more likely VM, then as soon as you login a terminal will spawn running the manage.py runserver command.  When you ctrl-C to kill the runserver command, the terminal will shutdown.  If you have systemd unit files installed, then you can simply run 'systemctl --user start manage_start.service' to spawn a new terminal running the dev server.

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

In the case of a production setup, when the scripts have finished running, you will need to open your firewall ports 80 and 443, and make sure that your router firewall is forwarding those two ports to your machine's ip address.

### server reload...

In the case of a production setup, if you make any changes to the code base, and need to reload the server, you can run the script 'reload.sh'.  This will call supervisorctl to reload the gunicorn process and then start and stop the swag container to reload nginx.

### customising scripts

If you want to add a container, or customise an existing container, you can either edit initial_provision.sh to install a new image, or customise/add a script to the container_scripts directory.
The script create_all.sh shells out to a bunch of scripts in that container_scripts directory.  In each of these scripts are a bunch of podman commands to bring up a container, and to customise it in some way.
The script get_variables.sh reads user input to get environment variables.  This then uses the envsubst command to complete a ./templates/env_files/scripts_env and ./templates/env_files/settings_env.
The scripts_env provides environment variables to the scripts, and the settings_env is copied to the directory /etc/opt/$PROJECT_NAME/settings to be read as and when by settings.py.
If you want to change any image tag then you will need to do so in the script ./initial_provision.sh and also the file ./templates/env_files/scripts_env.

### customising django_artisan

You can customise the settings of django_artisan, by editing the file settings.py in the settings directory.  Be aware that anywhere that os.getenv is used, are completed by the script ./scripts/get_variables.sh.   Places to customise are the text that is displayed in the header and in the about page - NAVBAR_SPIEL and ABOUT_US_SPIEL or the SITE_LOGO for example.

### make_manage_wsgi.sh

When the script create_all.sh is run (or called by initial_provision.sh) the entered project name is used to generate the files manage.py, and wsgi.py that are then copied over to the django_artisan folders.   Should you lose those files through a git pull of the django artisan code, you can recreate them using the script make_manage_wsgi.sh

### NB.

During the process of container creation you may see an error such as the following:
```
`WARN[0000] Error resizing exec session 327f2113dc9789d1b333000bc8296ace49ce4532`
`3ef0aa99ec2e4170e2e041fc: could not open ctl file for terminal resize for container`
` a5c87d9fdacfa546f648cedd43fba7d15a828e35b777e4bed3015dba9cd2d991: open /var/home`
`/pod_server/.local/share/containers/storage/overlay-containers/a5c87d9fdacfa54``6f648cedd43fba7d15a828e35b777e4bed3015dba9cd2d991/userdata/327f2113dc9789d1b33``3000bc8296ace49ce45323ef0aa99ec2e4170e2e041fc/ctl: no such device or address` 
```
This is due to a known bug in podman regarding the way it creates tty sizes.

Have fun!
