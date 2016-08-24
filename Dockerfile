FROM openjdk:jre

RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && echo "deb http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list \
    && echo "deb http://packages.entermediadb.org/repo/apt stable main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends entermediadb \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

ENV ENTERMEDIADB_ENDPOINT "/opt/entermediadb"
ENV ENTERMEDIADB_DATA "/media/data"
ENV ENTERMEDIADB_PORT "8080"

RUN useradd -ms /bin/bash entermedia

RUN sed -i 's/esac/foreground)\nsu $TOMCAT7_USER -c "$CATALINA_BASE\/bin\/catalina.sh run"\n;;\nesac/' /usr/share/entermediadb/tomcat/bin/tomcat.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/entermediadb/tomcat/bin/tomcat", "foreground"]