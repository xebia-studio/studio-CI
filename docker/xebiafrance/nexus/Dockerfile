# xebiafrance/nexus
#
# VERSION 2.10.0-02
FROM java:7
MAINTAINER Xebia

USER root
COPY cache/nexus.tar.gz /opt/

RUN cd /opt && tar xzf nexus.tar.gz && mv nexus-2.10.0-02 nexus && rm nexus.tar.gz && useradd nexus && chown nexus /opt -R

VOLUME /opt/sonatype-work

USER nexus

EXPOSE 8081

CMD ["/opt/nexus/bin/nexus","console"]