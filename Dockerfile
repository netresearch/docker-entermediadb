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

RUN useradd -ms /bin/bash entermedia

RUN sed -i 's/esac/foreground)\nsu $TOMCAT7_USER -c "$CATALINA_BASE\/bin\/catalina.sh run"\n;;\nesac/' /usr/share/entermediadb/tomcat/bin/tomcat.template

RUN cp -rp "/usr/share/entermediadb/conf/ffmpeg" "/home/entermedia/.ffmpeg" \
    && mv /etc/ImageMagick-6/delegates.xml /etc/ImageMagick-6/delegates.old \
    && cp -p "/usr/share/entermediadb/conf/im/delegates.xml" /etc/ImageMagick-6/ \
    && bash -c "mkdir -p /opt/entermediadb/tomcat/{logs,temp}" \
    && cp -rp "/usr/share/entermediadb/tomcat/conf" "/opt/entermediadb/tomcat" \
    && cp -rp "/usr/share/entermediadb/tomcat/bin" "/opt/entermediadb/tomcat" \
    && sed "s/%PORT%/8080/g" <"/usr/share/entermediadb/tomcat/conf/server.xml.template" >"/opt/entermediadb/tomcat/conf/server.xml" \
    && sed "s|%ENDPOINT%|/opt/entermediadb|g" <"/usr/share/entermediadb/tomcat/bin/tomcat.template" >"/opt/entermediadb/tomcat/bin/tomcat" \
    && echo "export CATALINA_BASE=\"/opt/entermediadb/tomcat\"" >> "/opt/entermediadb/tomcat/bin/setenv.sh" \
    && echo "export JRE_HOME=\"${JAVA_HOME}\"" >> "/opt/entermediadb/tomcat/bin/setenv.sh" \
    && chmod 755 "/opt/entermediadb/tomcat/bin/tomcat"
    
RUN cp -rp /usr/share/entermediadb/webapp /opt/entermediadb/ \
    && mkdir -p /media \
    && mv /opt/entermediadb/webapp/WEB-INF/data /media/data \
    && ln -s /media/data /opt/entermediadb/webapp/WEB-INF/data

EXPOSE 8080

COPY overrides /overrides

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/entermediadb/tomcat/bin/tomcat", "foreground"]