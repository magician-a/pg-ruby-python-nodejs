#Dockerfiles#

This repository contains files to build applications using Docker conteiners. 

#Image Creation#

This example creates the image with the tag:  **pg-ruby-python-nodejs/v1** , but you can
change this to use your own username.
```
$ docker build -t pg-ruby-python-nodejs/v1 .
```

After building, you can check listing the images you have locally on our host. 
You can do this using the **docker images** command like so:
```
$ docker images
REPOSITORY                 TAG                 IMAGE ID            CREATED              SIZE
pg-ruby-python-nodejs/v1   latest              92c1a8a66922        About a minute ago   1.304 GB
```

To run your container :
```
$ docker run -dit  -p 5432:5432 -p 6379:6379 -p 5672:5672 -p 15672:15672 pg-ruby-python-nodejs/v1 /bin/bash
```

After starting container, you can list running containers using the **docker ps** :

```
$ docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS           NAMES
729b1ae0f2b7        pg-ruby-python-nodejs/v1   "/scripts/run.sh /bin"   7 seconds ago       Up 6 seconds        0.0.0.0:5432->5432/tcp, 0.0.0.0:5672->5672/tcp, 0.0.0.0:6379->  79/tcp, 0.0.0.0:15672->15672/tcp   silly_ardinghelli
```

Check logs **docker logs {put CONTAINER ID from: docker ps}** :
```
$ docker logs 729b1ae0f2b7
```

If need enter into the container, you can using the next command **docker exec -it   {put CONTAINER ID from: docker ps}  /bin/bash -c " export TERM=xterm; exec bash;"** : 
```
$ docker exec -it  729b1ae0f2b7  /bin/bash -c " export TERM=xterm; exec bash;"
```

<<<<<<< HEAD
After first run, you can connect to the PostgreSQL as an administrator from the inside
the container. Default password for user **docker** is: **docker**
```
$ psql -h localhost -U docker docker
```
=======


>>>>>>> ba14027124b90c820050f24b201bc4ab2d3599d7


