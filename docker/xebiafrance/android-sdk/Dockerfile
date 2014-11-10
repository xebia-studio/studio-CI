# xebia/android-sdk
#
# VERSION 23.0.2
FROM ubuntu
MAINTAINER Xebia

ENV ANDROID_HOME /opt/android-sdk-linux
ENV JAVA_HOME /opt/jdk1.7.0_71
ENV M2_HOME /opt/apache-maven-3.2.3
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$M2_HOME/bin:$JAVA_HOME/bin:$PATH

# Add user jenkins to the image
RUN adduser --quiet jenkins
RUN echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

RUN mkdir /workspace
VOLUME ["/workspace"]
VOLUME ["/root"]

WORKDIR /

ADD cache/jdk-7-linux-x64.tar.gz    /opt
ADD cache/android-sdk-linux.tgz     /opt
ADD cache/apache-maven.tar.gz       /opt

RUN apt-get update
RUN mkdir -p /var/run/sshd
RUN apt-get install -y openssh-server
# Libraries required to build
RUN apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 zlib1g lib32z1

# Downloads the Platform and Build tools
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -u --all --filter platform-tools
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -u --all --filter build-tools-19.1.0,android-19
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -u --all --filter build-tools-21.1.1,android-21

CMD ["/usr/sbin/sshd", "-D"]
