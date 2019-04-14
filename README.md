# Wordpress Creator for Linux :rocket:
This little bash file will set up a new wordpress installation in your `public_html` folder in your home directory, a new virtual host and a new database (with default user or with a dedicated user for the project)

## What do you need to use it :question:
- You need to be under a Linux system (this script was developed and tested under Manjaro)
- You need to have Apache, mySQL and PHP installed (LAMP)

If you need to install Apache, mySQL and PHP you can refer to [this guide](https://www.ostechnix.com/install-apache-mariadb-php-lamp-stack-on-arch-linux-2016/).

## Usage :v:
1. Download the script and put it where you want (e.g. inside the `public_html`)
2. Make it executable
3. Run it with `sudo ./wp_new_project.sh`

:exclamation:**`sudo` is mandatory to launch the script, otherwise it will not have the right privileges to work properly**:exclamation:

It will create the new Wordpress project in 6 steps:
1. Set the name for the project (I usually use `projectname.local`)
2. Create the files and download the last version of Wordpress
3. Set the virtual hosts
4. Create the database
    - before it will ask you if you want to use the root user or to create a new user for the database
5. It saves all the information in the file `access_info.txt` inside the project folder

**TIP**
You can create a desktop launcher to start the script just with a double click. To do that, create a file and name it something like `wp_creator.desktop`and inside paste this code:
```
[Desktop Entry]
Version=1.0
Type=Application
Name=WP Creator
Comment=Build a new wordpress project
Exec=sudo xfce4-terminal -H -x pat/to/your/script
Icon=wordpress
Path=
Terminal=true
StartupNotify=false
```
(Remember to modify the file path).
