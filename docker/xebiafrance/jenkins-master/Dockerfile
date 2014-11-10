# xebiafrance/jenkins-master
#
# VERSION 1.0.0
FROM jenkins:1.584
MAINTAINER Xebia

USER root
RUN mkdir -p /tmp/WEB-INF/plugins
ADD cache/*.hpi /tmp/WEB-INF/plugins/
RUN cd /tmp ; zip -r --grow /usr/share/jenkins/jenkins.war WEB-INF
USER jenkins
