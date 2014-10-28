set -o xtrace
set -e 

## Data Volume run
docker run -d -v /var/jenkins_home --name jenkins-workspace iflowfor8hours/jenkins-master-data-volume /bin/bash

## The data volume has no data in it currently. Volumes are not a first class 
## concept in Docker at the present time, although the abstraction exists in the 
## code. We must use the `docker-volumes` tool to import the volume into the 
## container
cat workspace.tar | docker-volumes import jenkins-workspace 

## Master run
docker run -d -u root --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins sh -c '/usr/local/bin/jenkins.sh'
#
## Slave run
docker run -d --name=jenkins-slave -h jenkins-slave-1 --link jenkins-master:jenkins-master -e JENKINS_MASTER=http://jenkins-master:8080 maestrodev/build-agent 

echo "Your Jenkins master is running on http://localhost:`docker inspect --format='{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' jenkins-master`"


docker run -it --rm -v /var/jenkins_home --name jenkins-workspace iflowfor8hours/jenkins-master-data-volume /bin/bash

docker run -it --rm -u root --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins sh -c '/usr/local/bin/jenkins.sh'


docker run -it --rm --name=jenkins-slave -h jenkins-slave-1 --link jenkins-master:jenkins-master -e JENKINS_MASTER=http://jenkins-master:8080 maestrodev/build-agent            

