# What is this image?

The image contains a package of pre-installed `nginx (1.8.0) + php-fpm (5.6.8) + mysql (5.6.24)`. It can be used as 
a php development server, as a substitution for Vagrant VirtualBox provider

## Features:

1. Nginx is configured to automatically resolve all domains ending with `.dev`. 
It is very convenient: you can simply create the directory `test-app` (domain name without `.dev`) in the 
web document root and it will be available by the link `http://test-app.dev/` (NOTICE: it requires some preliminary 
configuration, see #additional software for detailed information). 

2. Pre-installed `composer` (with assets plugin), `git`, `phpmyadmin` (by default, automatic login 
as `root` without password).

3. It stores source codes and mysql data on the host machine, therefore you don't need to deploy your app each
time you start container. 

4. Php process run by user with UID 1000 (by default, the same UID as your host machine user), 
thus it can access all files. At the same time, you have all permissions for generated files.

# How to use this image

## additional software

For comfortable work, I suggest you to use [dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) for automatic resolving of such domains as `http://*.dev/`. 
You can install it in Ubuntu this way (run as `root`):

    apt-get install dnsmasq
    echo "address=/.dev/127.0.0.1" >> /etc/dnsmasq.conf
    
By default container binds `80` port on local `127.0.0.1:80`. If you are using another binding, change the 
ip address in the previous code to the one you use.

Other variant is to update `/etc/hosts` manually, each time adding something like this:

    127.0.0.1   my-app.dev

## how to run container

First of all you need install [Docker](https://www.docker.com/) on your machine. All command need run as root or you
need add your user to docker group.

    docker run --name dev-server -p 127.0.0.1:80:80 -v /opt/mysql:/var/lib/mysql -v /var/www:/web -d metalguardian/php-web-server

`--name dev-server` set container name, for simple access to it in the future: you can start, restart and 
stop the created container using its name: `docker start dev-server`

`-p 127.0.0.1:80:80` bind the port `80` of the container to the port `80` on the host machine (on 127.0.0.1 localhost)

`-v /opt/mysql:/var/lib/mysql` bind mount a volume of mysql data directory from host machine (`/opt/mysql`) to
container (`/var/lib/mysql`)

`-v /var/www:/web` bind mount a volume of source codes from host machine (`/var/www`) to container (`/web`)

`-d` detached mode: run the container in the background and print the new container ID

## how to access container terminal

You can access container terminal like this:

    docker exec -ti dev-server su docker
    
It logs you in the container as special user `docker`, witch can work with source code and console commands.

But if you need `root` privileges, run:

    docker exec -ti dev-server bash
    
It logs you in as `root`

## install new software

Before you can install some new packages, you need run (as `root`):

    apt-get update

Because all packages cache was cleaned while image was building

## other workflow

Alternatively, a simple `Dockerfile` can be used to generate a new image that
includes the necessary content (which is a much cleaner solution than the bind
mount above):

    FROM metalguardian/php-web-server
    COPY specific-nginx.conf /etc/nginx/conf.d/other-vhost.conf

Place this file in the directory, run `docker build -t some-other-server .`, then
start your container:

    docker run --name other-server -d some-other-server

# Supported Docker versions

This image is officially supported on Docker version 1.4.1.

Support for older versions (down to 1.0) is provided on a best-effort basis.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
 through a [GitHub issue](https://github.com/metalguardian/docker-webserver/issues).
