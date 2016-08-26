#!/bin/bash
set -e

cp -rpn /usr/share/entermediadb/webapp/WEB-INF/data/* /media/data

chown -R entermedia. /opt/entermediadb
chown -R entermedia. /media/data
chown -R entermedia:entermedia /home/entermedia

$@