set -o xtrace
set -e 

# Data Volume run
docker run -d -v /var/jenkins_home --name jenkins-workspace base /bin/bash

# Master run
# This needs some figuring out, will discuss later.
docker run -d -u root --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins sh -c '/usr/bin/curl -L https://updates.jenkins-ci.org/download/plugins/swarm/1.20/swarm.hpi -o /var/jenkins_home/plugins/swarm.hpi && /usr/local/bin/jenkins.sh'
# docker run -it -u root --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins sh -c '/usr/local/bin/jenkins.sh && /usr/bin/curl -L https://updates.jenkins-ci.org/download/plugins/swarm/1.20/swarm.hpi -o /var/jenkins_home/plugins/swarm.hpi && killall java && /usr/local/bin/jenkins.sh'

# Slave run
docker run -d --name=jenkins-slave --link jenkins-master:jenkins-master -e JENKINS_MASTER=http://jenkins-master:8080 maestrodev/build-agent

# interactive master 
# docker run -it -u root --rm --volumes-from jenkins-workspace -P --name jenkins-master -h jenkins-master jenkins /bin/bash
