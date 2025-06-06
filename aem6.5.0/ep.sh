#!/bin/bash
#trap "/opt/aem/crx-quickstart/bin/stop" ERR EXIT SIGINT
rm -rf /opt/aem/crx-quickstart/launchpad/felix/cache.lock
rm -rf /opt/aem/crx-quickstart/repository/segmentstore/repo.lock
java -Xmx2024m -server -Djava.awt.headless=true -jar aem-author-p4502.jar -forkargs -- -Xmx2024m
rm -rf /opt/aem/crx-quickstart/launchpad/felix/cache.lock
rm -rf /opt/aem/crx-quickstart/repository/segmentstore/repo.lock
#/opt/aem/crx-quickstart/bin/stop
