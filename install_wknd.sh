#!/bin/bash

export JAVA_HOME="`ls /usr/lib/jvm/* | grep oracle | sort | tr -d ':' | head -n1`"
#wkndroot='/var/tmp/aem-guides-wknd'
wkndroot="/tmp/aem-guides-wknd"
ls $wkndroot || git clone https://github.com/adobe/aem-guides-wknd $wkndroot


await6x() {

  #await until package manager is up
	port=$1

  while true; do
    docker ps | grep acs && break
    curl -s -u admin:admin -F cmd=ls http://localhost:$port/crx/packmgr/service.jsp | grep '<name>aem-service-pkg' && break
    echo "Awaiting service pacakge installation" >&2
    sleep 250
	done

  while true; do
    sleep 2
    curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp > /dev/null || continue
    if curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp | grep -iE '<status code="?200"?>ok' ; then
      break
    fi
    echo "Awaiting until package manager is up" >&2
    sleep 250
    continue
  done
}

if docker ps | grep acs; then
  classic=''
else
  classic=-Pclassic
fi

cd $wkndroot
git pull
await6x 4502
mvn clean install -PautoInstallSinglePackage ${classic}
await6x 4503
mvn clean install -PautoInstallSinglePackagePublish ${classic}

