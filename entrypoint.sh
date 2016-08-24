#!/bin/bash
set -e

ENTERMEDIADB_HOME="/usr/share/entermediadb"

cp -rp "${ENTERMEDIADB_HOME}/conf/ffmpeg" "/home/entermedia/.ffmpeg"
mv /etc/ImageMagick-6/delegates.xml /etc/ImageMagick-6/delegates.old
cp -p "${ENTERMEDIADB_HOME}/conf/im/delegates.xml" /etc/ImageMagick-6/
mkdir -p "${ENTERMEDIADB_ENDPOINT}/tomcat"/{logs,temp}
cp -rp "${ENTERMEDIADB_HOME}/tomcat/conf" "${ENTERMEDIADB_ENDPOINT}/tomcat"
cp -rp "${ENTERMEDIADB_HOME}/tomcat/bin" "${ENTERMEDIADB_ENDPOINT}/tomcat"
sed "s/%PORT%/8080/g" <"${ENTERMEDIADB_HOME}/tomcat/conf/server.xml.template" >"${ENTERMEDIADB_ENDPOINT}/tomcat/conf/server.xml"
sed "s|%ENDPOINT%|${ENTERMEDIADB_ENDPOINT}|g" <"${ENTERMEDIADB_HOME}/tomcat/bin/tomcat.template" >"${ENTERMEDIADB_ENDPOINT}/tomcat/bin/tomcat"
echo "export CATALINA_BASE=\"${ENTERMEDIADB_ENDPOINT}/tomcat\"" >> "${ENTERMEDIADB_ENDPOINT}/tomcat/bin/setenv.sh"
echo "export JRE_HOME=\"${JAVA_HOME}\"" >> "${ENTERMEDIADB_ENDPOINT}/tomcat/bin/setenv.sh"
chmod 755 "${ENTERMEDIADB_ENDPOINT}/tomcat/bin/tomcat"

mkdir -p "${ENTERMEDIADB_ENDPOINT}/webapp"/{WEB-INF,media}
cp -p "${ENTERMEDIADB_HOME}/webapp/media/_site.xconf" "${ENTERMEDIADB_ENDPOINT}/webapp/media"
cp -rp "${ENTERMEDIADB_HOME}/webapp/"* "${ENTERMEDIADB_ENDPOINT}/webapp/" 2> /dev/null
cp -rp "${ENTERMEDIADB_HOME}/webapp/assets" "${ENTERMEDIADB_ENDPOINT}/webapp/" 2> /dev/null
cp -rp "${ENTERMEDIADB_HOME}/webapp/theme" "${ENTERMEDIADB_ENDPOINT}/webapp/"
cp -p "${ENTERMEDIADB_HOME}/webapp/WEB-INF/node.xml" "${ENTERMEDIADB_ENDPOINT}/webapp/WEB-INF/"
cp -p "${ENTERMEDIADB_HOME}/webapp/WEB-INF/web.xml" "${ENTERMEDIADB_ENDPOINT}/webapp/WEB-INF/"
cp -rp "${ENTERMEDIADB_HOME}/webapp/WEB-INF/"{bin,base,lib} "${ENTERMEDIADB_ENDPOINT}/webapp/WEB-INF/"

if [[ ! -d "${ENTERMEDIADB_DATA}" ]]; then
      mkdir -p "${ENTERMEDIADB_DATA}"
fi

cp -rpn "${ENTERMEDIADB_HOME}/webapp/WEB-INF/data/"* "${ENTERMEDIADB_DATA}"
ln -sf "${ENTERMEDIADB_DATA}" "${ENTERMEDIADB_ENDPOINT}/webapp/WEB-INF/data"
chown -R entermedia. "${ENTERMEDIADB_ENDPOINT}"
chown -R entermedia. "${ENTERMEDIADB_DATA}"
chown -R entermedia:entermedia /home/entermedia

$@