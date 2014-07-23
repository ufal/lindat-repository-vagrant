#!/bin/bash
#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#
# puppet dependency hell - instead of complicated setup let's move it here
#
# Downloads probe, copies to webapps, updated permissions and restarts tomcat
#

echo "======================================================================="
echo " "
echo "======================================================================="
echo "Linking probe.war to tomcat's webapps an restarting tomcat"
echo "Using TOMCAT=$TOM_VERSION"
echo "======================================================================="

# Vagrantfile -> puppet -> OS environment variable
TOMCAT=tomcat$TOM_VERSION

PROBE_VER=2.3.3
echo "Downloading version ${PROBE_VER}"
wget -q http://psi-probe.googlecode.com/files/probe-${PROBE_VER}.zip 
unzip probe-${PROBE_VER}.zip -d /tmp
sudo mv /tmp/probe.war /var/lib/$TOMCAT/webapps/probe.war
sudo chown -R $TOMCAT:$TOMCAT /var/lib/$TOMCAT/webapps/
sudo service $TOMCAT restart
rm probe-${PROBE_VER}.zip
