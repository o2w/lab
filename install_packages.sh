#!/bin/bash

if [ "$1" = "author" ]; then
  port=4502
else
  port=4503
fi

srcdir=$2

install_package() {
  package="$1"

  echo "package=$package"

  #await until package manager is up
  while true; do
    sleep 2
    curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp > /dev/null || continue
    if curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp | grep -iE '<status code="?200"?>ok' ; then
      break
    fi
    echo "Awaiting until package manager is up" >&2
    sleep 16
    continue
  done

  echo "upload package=$package"
  curl -u admin:admin -F file=@"$package" -F name="$package" -F force=true -F install=true http://localhost:$port/crx/packmgr/service.jsp
  echo "awaiting package installation"
  sleep 24
  while true; do
    #curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp || continue
    curl -s -u admin:admin http://localhost:$port/crx/packmgr/service.jsp | grep -iE '<status code="?200"?>ok' && break
    echo "still awaiting package installation"
    sleep 8
  done
  echo "package $package installation done"
}

echo "Package manager confirmed up" >&2

#~/Downloads/aem/src/packages/sp/aem-service-pkg-6.5.9-1.0.zip
servicepack="`find $srcdir -type f -iname "aem-service-pkg*.zip" | head -n 1`"

curl -u admin:admin -F cmd=ls http://localhost:$port/crx/packmgr/service.jsp | grep '<name>aem-service-pkg'
if [ $? = 1 ]; then
  echo "No service package found on instance, installing $servicepack" >&2
  install_package $servicepack
fi

#open http://localhost:$port/crx/packmgr/index.jsp
#https://helpx.adobe.com/experience-manager/kb/common-AEM-Curl-commands.html
ls $srcdir/*.zip | grep -v 'aem-service-pkg' | grep -v 'cq-quickstart' | while read p; do
  ls -alh $p | awk '{print $5}' | grep -iE '[0-9\.]+G' && echo "$p is too large. Skipping" && continue
  install_package $p
done
#ls $src/packages/sp/*.zip | while read p; do
#  echo "package=$p" >&2
#  while true; do
#    curl -u admin:admin -F file=@"$p" -F name="$p" -F force=true -F install=true http://localhost:$port/crx/packmgr/service.jsp && break
#    sleep 48
#  done
#done
