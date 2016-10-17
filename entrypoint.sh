#!/bin/bash
set -e

cp -rpn /usr/share/entermediadb/webapp/WEB-INF/data/* /media/data

for d in /overrides/*/ ; do
    cp -r "$d"* /opt/entermediadb/webapp;
done

chown -R entermedia. /opt/entermediadb
chown -R entermedia. /media/data
chown -R entermedia:entermedia /home/entermedia

# Hoped this could fix https://github.com/entermedia-community/app-emshare/issues/7
# but it doesn't
#/opt/entermediadb/tomcat/bin/tomcat start
#sleep 2
#curl --retry 3 -H "Content-Type: application/json" -X POST http://localhost:8080/mediadb/services/authentication/login -d '{"id": "admin", "password": "admin"}'
#/opt/entermediadb/tomcat/bin/tomcat stop

$@