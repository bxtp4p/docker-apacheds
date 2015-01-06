# A docker file to produce an apache directory container for



FROM  java:7-jre

MAINTAINER Yves.Nicolas@dynamease.com

ENV APACHEDSVER 2.0.0-M19

RUN apt-get update && apt-get install -y ldap-utils wget  && rm -rf /var/lib/apt/lists/*

# Create apacheds user
RUN useradd  -u 1000 -U -s /bin/bash apacheds


# Download apacheds debian installer and run it

WORKDIR /tmp
RUN wget http://archive.apache.org/dist/directory/apacheds/dist/$APACHEDSVER/apacheds-$APACHEDSVER-amd64.deb \
    && dpkg -i apacheds-$APACHEDSVER-amd64.deb


# Expose data directory as a volume
VOLUME /var/lib/apacheds-$APACHEDSVER

EXPOSE 10389

ENV PATH $PATH:/opt/apacheds-$APACHEDSVER/bin

# starts apache  ds
USER apacheds
WORKDIR /var/lib/apacheds-$APACHEDSVER
CMD ["apacheds", "console", "default"]
