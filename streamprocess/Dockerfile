FROM registry.dataos.io/guestbook/mvn:storm_kafka_dep
ARG STORMCLASSNAME 
ARG STROMNHOST 
ARG STORMJARNAME 
ARG STORMJARVER
COPY . /sourcefile
WORKDIR /sourcefile
RUN mvn package
#RUN chmod +x /sourcefile/set_dns.sh
#RUN /sourcefile/set_dns.sh
RUN /opt/apache-storm/bin/storm jar target/"${STORMJARNAME}"-"${STORMJARVER}".jar "${STORMCLASSNAME}" "${STROMNHOST}" 