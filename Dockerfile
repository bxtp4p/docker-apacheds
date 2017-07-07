# A docker file to produce an apache directory container
FROM  java:8-jre

MAINTAINER Yves.Nicolas@dynamease.com

ENV APACHEDSVER 2.0.0-M23

RUN apt-get update && apt-get install -y ldap-utils wget  && rm -rf /var/lib/apt/lists/*

# Create apacheds user
RUN useradd -U -s /bin/bash apacheds


# Download apacheds debian installer and run it

WORKDIR /tmp
RUN wget http://archive.apache.org/dist/directory/apacheds/dist/$APACHEDSVER/apacheds-$APACHEDSVER-amd64.deb \
    && dpkg -i apacheds-$APACHEDSVER-amd64.deb


# Expose data directory as a volume
VOLUME /var/lib/apacheds-$APACHEDSVER

EXPOSE  10389 10636 60088 60464 8080 8443

ENV PATH $PATH:/opt/apacheds-$APACHEDSVER/bin

# starts apache  ds

# Copy Scripts
COPY initds.sh /usr/local/sbin/

# Change default apache ds script
COPY apacheds-script /opt/apacheds-$APACHEDSVER/bin/
RUN mv /opt/apacheds-$APACHEDSVER/bin/apacheds /opt/apacheds-$APACHEDSVER/bin/apacheds.bak \
    && mv /opt/apacheds-$APACHEDSVER/bin/apacheds-script /opt/apacheds-$APACHEDSVER/bin/apacheds

# Copy Admin Password change template
COPY admin_password.ldif /tmp/


USER apacheds
WORKDIR /var/lib/apacheds-$APACHEDSVER

# Entrypoint script will load the appropriate ldifs and start apacheds
ENTRYPOINT ["initds.sh"]
