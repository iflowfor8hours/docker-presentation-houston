### Jenkins on Docker Automated CI infrastructure 


This is one way to set up a jenkins cluster with build slaves on almost any machine with docker installed. 

## Usage

From the `livedemo` directory, run the `runjenkins.sh` script.

you man also choose to follow along with me below for the interactive version. Keep in mind these run everythingin the foreground, so you'll want a bunch of terminals open and organized.

## Now what's going on here? 

`docker run -it --rm -v /var/jenkins_home --name jenkins-workspace base /bin/bash`

This will configure a data volume named jenkins-worspace, which will me mount in the `jenkins-master` continer to contain all the stateful data of the jenkins master. This is the area where the jenkins jobs and history are stored, in addition to the master configuration values.

The data volume has no data in it currently. Volumes are not a first class concept in Docker at the present time, although the abstraction exists in the code. We must use the `docker-volumes` tool to import the volume into the jenkins-workspace container. Notice the seperation of the volume and container concepts.

`cat workspace.tar | docker-volumes import jenkins-workspace`

Then we use a volume image and the `docker-volumes` tool to fill that container with the static jenkins configuration data we want the master to use. In this case, it is a set of plugins and some configuration options. 

`docker run -it --rm -u root --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins sh -c '/usr/local/bin/jenkins.sh'`

This starts the `jenkins-master` container, and mounts the `/var/jenkins_data` directory before starting the jenkins server process. The jenkins server process initializes with the data we mounted from the other container. This technique creates a physical seperation of data and compute processes. This pattern comes in very handy in more complex or scaled infrastructures. This also exports them to the host through localhost and to any other containers if configured to do so. In our case, we specified that ports 8080 and 50000 to be open to the world, so this exposes them to linked containers and the host machine the container is running on. 

`docker run -it --rm --name=jenkins-slave -h jenkins-slave-1 --link jenkins-master:jenkins-master -e JENKINS_MASTER=http://jenkins-master:8080 maestrodev/build-agent`
