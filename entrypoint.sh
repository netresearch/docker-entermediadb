#!/bin/bash
set -xe
EMDB_SOURCE=/usr/share/entermediadb
EMDB_TARGET=/opt/entermediadb
EMDB_WEBAPP=${EMDB_TARGET}/webapp
EMDB_MEDIA=/media/data

# application data
if [[ ! -d "${EMDB_WEBAPP}/assets/emshare" ]]; then
    mkdir -p "${EMDB_WEBAPP}"
    cp -ar "${EMDB_SOURCE}/webapp" "${EMDB_TARGET}"
fi

if [[ ! -d "${EMDB_MEDIA}/system" ]]; then
    mkdir -p "${EMDB_MEDIA}"
    cp -arn "${EMDB_WEBAPP}/WEB-INF/data" "/media"
    rm -rf "${EMDB_WEBAPP}/WEB-INF/data"
    ln -s "${EMDB_MEDIA}" "${EMDB_WEBAPP}/WEB-INF/data"
fi

rsync -ar --delete --exclude '/WEB-INF/data' --exclude '/WEB-INF/elastic'  ${EMDB_SOURCE}/webapp/WEB-INF ${EMDB_WEBAPP}

# tomcat data
if [[ ! -d "${EMDB_TARGET}/tomcat/conf" ]]; then
    mkdir -p ${EMDB_TARGET}/tomcat/{logs,temp}
    cp -rp  ${EMDB_SOURCE}/tomcat/{bin,conf}  "${EMDB_TARGET}/tomcat"
    sed "s/%PORT%/8080/g" < "${EMDB_SOURCE}/tomcat/conf/server.xml.template" > "${EMDB_TARGET}/tomcat/conf/server.xml"
    sed "s|%ENDPOINT%|/opt/entermediadb|g" < "${EMDB_SOURCE}/tomcat/bin/tomcat.template" > "${EMDB_TARGET}/tomcat/bin/tomcat"
    echo "export CATALINA_BASE=\"${EMDB_TARGET}/tomcat\"" >> "${EMDB_TARGET}/tomcat/bin/setenv.sh"
    echo "export JRE_HOME=\"${JAVA_HOME}\"" >> "${EMDB_TARGET}/tomcat/bin/setenv.sh"
    chmod 755 "${EMDB_TARGET}/tomcat/bin/tomcat"
fi

rsync -ar --delete \
    --exclude '/tomcat/bin/setenv.sh' \
    --exclude '/tomcat/bin/tomcat' \
    --exclude '/tomcat/conf/server.xml'\
    --exclude '/tomcat/conf/tomcat-users.xml' \
    --exclude '/tomcat/logs/*' \
    --exclude '/tomcat/conf/node.xml' \
    $EMDB_SOURCE/tomcat $EMDB_TARGET/

# apply overrides
for d in /overrides/*/ ; do
    cp -r "$d"* /opt/entermediadb/webapp;
done

# set file ownerships
chown -R entermedia. /opt/entermediadb
chown -R entermedia. /media/data
chown -R entermedia. /home/entermedia

# Hoped this could fix https://github.com/entermedia-community/app-emshare/issues/7
# but it doesn't
#/opt/entermediadb/tomcat/bin/tomcat start
#sleep 2
#curl --retry 3 -H "Content-Type: application/json" -X POST http://localhost:8080/mediadb/services/authentication/login -d '{"id": "admin", "password": "admin"}'
#/opt/entermediadb/tomcat/bin/tomcat stop

$@