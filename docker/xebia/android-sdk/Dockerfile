# xebia/android-sdk
#
# VERSION 23.0.2
FROM ubuntu
MAINTAINER Xebia

ENV ANDROID_URL cache/android-sdk-linux.tgz
ENV ANDROID_HOME /android-sdk-linux
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

WORKDIR /
ADD $ANDROID_URL /
RUN apt-get update
RUN apt-get install -y openjdk-7-jdk openssh-server
# Libraries required to build
RUN apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 zlib1g lib32z1

RUN mkdir -p /var/run/sshd

# Downloads the Platform and Build tools, App Support and Play Services SDKs
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -u --all --filter platform-tool-19.1.0,build-tools-19.1.0,android-19,105,106,4,2

# Add user jenkins to the image
RUN adduser --quiet jenkins
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

RUN mkdir /workspace
VOLUME ["/workspace"]

VOLUME ["/root"]

CMD ["/usr/sbin/sshd", "-D"]
