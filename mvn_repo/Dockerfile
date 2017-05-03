FROM registry.dataos.io/library/maven:3-jdk-8

COPY repository /root/.m2/repository
COPY settings.xml /usr/share/maven/conf/settings.xml

#install storm env
RUN sed -i "s/http:\/\/httpredir.debian.org/http:\/\/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    sed -i "s/http:\/\/security.debian.org/http:\/\/mirrors.aliyun.com\/debian-security/g" /etc/apt/sources.list
# 0.10.0
ENV STORM_VERSION 0.10.0
ENV APACHE_MIRROR http://mirrors.aliyun.com/apache/storm
ENV KAFKA_DEP v0.3
RUN apt-get update && apt-get install -y python wget  tar git

RUN curl -o /opt/apache-storm.tar.gz ${APACHE_MIRROR}/apache-storm-${STORM_VERSION}/apache-storm-${STORM_VERSION}.tar.gz && \
    tar -C /opt -xzf /opt/apache-storm.tar.gz && \
    rm /opt/apache-storm.tar.gz && \
    mv /opt/apache-storm-${STORM_VERSION} /opt/apache-storm

COPY storm-dep/ /opt/apache-storm/lib
COPY build.sh /build.sh
CMD ["/build.sh"]
