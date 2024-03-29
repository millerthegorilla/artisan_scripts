# artisan_scripts
scripts to provision django_artisan ... https://github.com/millerthegorilla/django_artisan

### license
As poor as these scripts are, and keeping in mind I accept no responsibility for any errors or headaches they may create, they are released, like Django Artisan, under an MIT license.

### containers
Currently the script installs into a standard user account, containers:
* a customised python container, with a venv and packages from dockerfiles/pip_requirements_dev/_prod.  The runserver command runs inside here and the django_artisan codebase is mounted into the container.
* a customised mariasql container.  The database is stored in a volume mount that is mounted each time the container is recreated, ie the container can be recreated from scratch and is each time the machine restarts, for example, but the database persists.
* a clamd container.  This is used to scan images when they are uploaded.
* a duckdns container.  This is used to update the dns record at duckdns.org for the site.
* an elasticsearch container.  This is used to provide elasticsearch capabilities to django_artisan.
* a redis container.  This is used for caching for the site, for the thumbnail images and for djangoq, an asynchronous task scheduler.
* swag.  This is the linuxserver.io container, which provides an nginx reverse proxy, and https via letsencrypt.

The containers are recreated from scratch each time the machine restarts or if they have shutdown and are restarted with systemd commands.  The database, and codebase persists, as do static files, which in the case of a production install, are served by the nginx reverse proxy via a volume mount.

### requirements...

You will need the following created and ready...
* a linux system running a reasonably recently updated podman (tested >=2.2)
* user account on that system, that, in the case of production, is preferably created
  with ```$useradd -g 2000 (ie not std 1000) -u 2000 -s /sbin/nologin  username```
* a duckdns account, with your token and subdomain address at the ready
* a gmail account that sends email
* an app password for that account (you need to set up 2 step verification... https://support.google.com/accounts/answer/185833?hl=en")
* google recaptcha public key   https://developers.google.com/recaptcha/intro
* google recaptcha private key
* the path to the directory where you have cloned django_artisan : https://github.com/millerthegorilla/django_artisan
#### optional
* a top level url, such as www.ceramicisles.org that you own and can access.  You can then point the domain at the duckdns address, or place an nginx reverse proxy or similar at the url address pointing to the duckdns address.  The ```./artisan_run create [variables]``` will prompt for the top level domain, and configure the swag container automatically.

I run the production install on a raspberry pi 4b with 8gb of RAM, running fedora coreos (currently).  I have a user created with /sbin/nologin shell, and with lingering enabled (```loginctl --enable-linger $USERNAME```).  I have secured ssh ```https://www.redhat.com/sysadmin/eight-ways-secure-ssh```.  I also have installed fail2ban, and have set the firewall to be as restrictive as possible, and have disabled any services that I don't need.

With the immutable file system of coreos, and the rootless configuration of podman, the server should theoretically be quite secure. 

I run the development install inside a gnome-boxes VM.  This allows me to restart the host if necessary, without restarting the machine.

### disclaimer...

These scripts are provided as is, with no support, and the author accepts nil responsibility for any damage or otherwise that using these scripts may cause.  They are alpha, permanently, so proceed with care.  The scripts have only been tested on machines running Fedora CoreOs, ie Silverblue and Fedora IOT.

I have tested them on a newly installed system, in my case a raspberry pi running Fedora IOT.

### Swag Secure Web Application Gateway - nginx container

The scripts set up containers and environment necessary to run django_artisan as an SSL enabled site.  The SSL service is provided by the LinuxServer team's SWAG image (https://hub.docker.com/r/linuxserver/swag) SWAG stands for Secure Application Gateway, apparently.  Inside the container, letsencrypt certbot runs to generate SSL certificates, and is configured in this instance to provide SSL certs for a duckdns subdomain and for a single extra TLD domain.  I use duckdns subdomain to point at the nginx container, and then use a TLD domain, to act as a redirect to the duckdns subdomain.  The site then runs on my home server, and the only cost I have is renewal of the TLD domain name, as it then gets listed in Google search etc, where the duckdns subdomain is ignored.  [*EDIT - I now use the duckdns subdomain exclusively, as it works fine and is listed in google ok, and doesn't cost me a bean.]

### what to do...

Before running the scripts, download them into a directory in your home folder, and git clone the django_artisan code into a directory.  Then run the command ./artisan_run install.  This will set the artisan scripts directory owners and permissions.  All artisan_run commands must be run as root, ie sudo or similar.

Then run the script artisan_run.sh which takes one command to direct it to the correct scripts.
The commands are clean, create [ variables, directories, images, containers, systemd ], help, install, interact, manage, postgit, refresh, replace, reload, status, settings, or update.

* ```./artisan_run clean```

If at any point the scripts fail or you break out of them, you can run the script cleanup.sh to remove the containers and to reset the script environment to the beginning.

To clean up completely, run the ```./artisan_run clean```, answer yes to code removal, and to image removal, and to log removal.

* ```./artisan_run create```

The create verb runs the script create_directories.sh and then checks the podman images, and downloads them and/or builds them as necessary, in the script initial_provision.sh.  Then the script 'create_all.sh' is called which creates and provisions the containers.  Depending on your options, either a development setup will be created, running manage.py on port 8000, or a production setup will be created, opening ports 443 and 80.  In any case the create_directories.sh script will edit and reload sysctl to lower the available port numbers to 80.  Be aware that this can be a ***SECURITY ISSUE***.  As long as you manage your firewall sensibly it should be ok.
Be aware that on a first install, or if rebuilding the custom image, this command takes a long time, as it builds the custom images from the dockerfiles.   When the custom images have been made, rerunning this command is reasonably quick.

* ```./artisan_run create [ variables, templates, directories, network, pull, build, settings, pods, containers, systemd ]```

Create the appropriate section of the install.  Variables asks for appropriate variables, directories creates the directories, network lowers the ports, pull downloads the images, build builds custom containers, settings chooses the settings file, pods creates any defined pods, containers creates the containers and systemd creates the systemd files that start the containers and installs them.  Once systemd has run either on its own, or as part the create verb, the containers will be replaced at startup of host machine.   In the case of a development install, when you start the host machine, two terminal windows will open when you login, one displaying the output from the runserver command, and the other displaying output from the qcluster that is part of djangoQ.  After systemd install has finished, you can run the runserver command in a shell in the $USERNAME account with ```systemctl --user start manage_start.service``` and the djangoq cluster with ```systemctl --user start qcluster_start.service```.

In the case of a production install, it is best to create the system account with a shell set to /usr/bin/nologin and enable lingering for the account ie loginctl --enable-linger $USERNAME

* ```./artisan_run install```

This verb installs the artisan scripts, making certain that the directories and files are set to their most restrictive permissions.  All artisan_run commands require the commands to be run as root, ie sudo.  So, when you first clone this repository, immediately run ```sudo ./artisan_run install```

* ```./artisan_run uninstall```

This does the opposite of the install command, and puts files and directories back to the permissions that they had on the remote git repo.  So, when you want to git pull, you need to run this command first, or git will complain about unreachable files etc...

* ```./artisan_run custom interact```

This command attempts to run the command that follows 'interact' in the correct systemd context of the user account.   There are a few ways to do this, such as `su $USERNAME && command` or `runuser $USERNAME` etc.   For example, I often start a shell in the $USERNAME account and then run the command `podman exec -it container_name bash`, and then work inside the container.

* ```./artisan_run custom manage```

The manage verb is an alias for running the runserver command inside the podman container, with whatever command follows, ie:
`sudo ./artisan_run custom manage makemigrations`

* ```./artisan_run custom postgit```

This command runs inside the containers and sets the directories and files to the strictest permissions possible.

* ```./artisan_run custom pip```

This command allows you to interact with pip inside the django container, using the correct user account/prefix etc.

* ```./artisan_run refresh```

This command deletes and remakes the containers from the images.  It is an alias for `./artisan_run create images`.  When the images have been rebuilt the host machine is restarted.

* ```./artisan_run custom replace```

This verb takes the manage.py and the wsgi file as templates from artisan_scripts and copies them over to the appropriate locations within the django_artisan folder structure completed with the appropriate options.

* ```./artisan_run custom reload```

Aimed at production installs, this command kills the gunicorn process, and then restarts it.

* ```./artisan_run status```

This prints some details about the running project, if it is running, the username etc

* ```./artisan_run custom settings```

Because the settings.py file for django_artisan code base is stored in this codebase, you can create different settings files for different git branches of django_artisan.  So, this verb asks you to choose from a settings file, and then copies that settings file into the project directory appropriately and sets ownership/permissions etc
To create a settings file, simply copy an existing one and paste it into the appropriate directory, either ${SCRIPTS_ROOT}/settings/development or ${SCRIPTS_ROOT}/settings/production 

* ```./artisan_run update```

This command attempts to run a package update in all of the containers.  When you run the `artisan_run create` command, you can select to update the containers the systemd way, which will check for an updated container in the registry, and pull it and restart the container if one exists.
https://www.redhat.com/sysadmin/podman-auto-updates-rollbacks

### systemd

When the systemd units have been created and installed, be aware that the podman container systemd units are created with the --new flag.  This completely breaks down and rebuilds the containers as clean, whenever the systemd unit shuts down/the host machine restarts etc.  The database is maintained in its current state despite the container being created from scratch.

### django_artisan development

It is a sensible idea to only make changes to the django_artisan codebase when the development server is up and running.  If you run `artisan_run clean` and take down and remove the pod and containers, and then make changes to the django_artisan codebase, then if there are any bugs, then when you run `artisan_run create` the script will fail if there are any bugs.  You can comment changes or fix the bugs, but until either of these `artisan_run create` will fail.  In order to see the output, start a shell in the $USERNAME account and then run the command `podman exec -it $DJANGO_CONTAINER_NAME bash`.  This will open a shell in the container (defaults to the name 'django_cont'), where you can then run the command `python /opt/$PROJECT_NAME/manage.py runserver 0.0.0.0:8000` to see the output.
If you want to add a pip package to the installation, then you can run the command `podman exec -it $DJANGO_CONTAINER bash`.  $DJANGO_CONTAINER defaults to the string 'django_cont'.  When you are inside the container, activate the venv by running the command `source /home/artisan/bin/activate`.  Then run the command `pip install [package_name]`.  Once you are happy that you are keeping that package, you can edit the file 'pip_requirements_dev' or 'pip_requirements_prod' (or both), inside the dockerfiles directory.  I tend to add the package version number as standard to make sure I get a known working version. 

### options

There is a file in the root directory called 'options'.  I am using Gnome 3, so the TERMINAL_CMD is set to 'gnome-terminal --'.   If you are using xterm, then you will want to edit the file and change TERMINAL_CMD to 'xterm -e' etc etc.
The TERMINAL_CMD is used to spawn a terminal in the case of using a development install.  In this case when you start your machine, or more likely VM, then as soon as you login a terminal will spawn running the manage.py runserver command.  When you ctrl-C to kill the runserver command, the terminal will shutdown.  If you have systemd unit files installed, then you can simply run 'systemctl --user start manage_start.service' to spawn a new terminal running the dev server.

```CONTAINER_SCRIPTS_ROOT="${SCRIPTS_ROOT}/container_scripts"``` 
container scripts root is a convenient path to the scripts that have the container information in.  See the podbash project... (https://github.com/millerthegorilla/podbash)

```DEFAULT_PROJECT_FILE=```  this is a path to a file that contains the default project settings.

```PROJECT_SETTINGS="${SCRIPTS_ROOT}/.PROJECT_SETTINGS"``` the environment variable PROJECT_SETTINGS refers to the project settings file throughout the code, and the default is to locate a file in the scripts root called '.PROJECT_SETTINGS'.  If you set a DEFAULT_PROJECT_FILE or select a file from the settings_files directory, or if you manually enter the variables, the settings in each case get copied to the location of PROJECT_SETTINGS in the options file.

RUN_FILES='pre,run,post' - a comma delimited list of the files called in creating the container, in order.

LOCAL_SETTINGS_FILE="./settings.sh" - as you answer questions when defining the project variables, each container's question's answers are stored in the LOCAL_SETTINGS_FILE, which defaults to a file called settings.sh, that is in the same directory as the questions.

### error output and logs

If you want to see error output whilst in development mode, then you can open a terminal and run the command
```
tail -f ${HOME}/${PROJECT_NAME}/logs/django/debug.log
```
In either a production or development install logs are stored in that location.  You can access django logs from that location, according to the settings at the end of settings.py.

the swag container is set to create its logs as ${HOME}/${PROJECT_NAME}/swag_logs

### directory structure 

The directory structure on the host machine is:

* for settings.py and gunicorn.conf.py :
    settings files -> /etc/opt/$PROJECT_NAME/settings/
* in the case of a production install, for static files there is symlink to django code/static and django code/media in the following location which is referenced by the nginx set up in the swag container which volume mounts static_files:
    static files -> /etc/opt/$PROJECT_NAME/static_files/
* in the case of a development install the static and media files are located in the django_artisan code base directory.
    
* log file directories are volume mounted into the same host dir from the swag container and the django container:
    log files -> $HOME/$PROJECT_NAME/logs

* django code resides at -> /opt/$PROJECT_NAME/ which is a symbolic link to the code inside the django_artisan repo, wherever you have cloned that to.  So clone django_artisan to any directory you wish, and then the script will ask you for project_name and for the path to your code, and then symlink from opt to the django_artisan code directory.

### .env file

When you have run the get_variables script or `./artisan_run create [ variables ]` an .env file that is read by the command os.getenv inside the settings.py file, is created in the /etc/opt/$PROJECT_NAME/settings/ directory.  This file is readable by $USERNAME by default, for ease of development etc.  The best strategy for production is to start gunicorn, which reads the settings in the wsgi.py file, and once the server has started, then change the owner/permissions of the .env file to root/restrictive.  This may become part of the scripts in the future...

### firewall and router...

In the case of a production setup, when the scripts have finished running, you will need to open your firewall ports 80 and 443, and make sure that your router firewall is forwarding those two ports to your machine's ip address.

### customising django_artisan

You can customise the settings of django_artisan, by editing the file settings.py in the settings directory.  Be aware that anywhere that os.getenv is used the variables are loaded into the environment from /etc/opt/${PROJECT_NAME}/.env.   Places to customise are the text that is displayed in the header and in the about page - NAVBAR_SPIEL and ABOUT_US_SPIEL or the SITE_LOGO for example.

### Podman

You will want to read about podman generally, http://docs.podman.io/en/latest/index.html, 
but to list the containers, on your host machine or VM type in a terminal that is in the $USERNAME account:
```
podman ps
```
You can then see the list of active containers, and establish the name of the container you wish to exec into.
```
podman exec -it mariadb_cont bash
```
for example, to inspect the database (ie run mysql -uroot -p$PASSWORD).   http://docs.podman.io/en/latest/markdown/podman-exec.1.html

### customising scripts / using artisan_scripts with different projects...

There is no reason that you can't use artisan scripts with a different django project, just fork this project and edit as necessary.

In the case of django projects, the current python image is used to contain the codebase and to create a venv and pip install the requirements.  There is a different image dockerfile for production and development.  You can find the specific dockerfiles and requirements.txt files in the 'dockerfiles' directory.  For django_artisan there is a custom swag image (which you may want to keep), and a custom database image.


### Podbash

If you want to customise the project then there are instructions on how to do so at https://github.com/millerthegorilla/podbash.

## Have fun!
