#!/bin/bash
#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#
# Final touches because it is easier to make them here as in puppet and
#


echo "======================================================================="
echo "="
echo "======================================================================="
echo "Last touches to original dspace installation" 
echo "Using TOMCAT=$TOM_VERSION and REPO_BRANCH=$REPO_BRANCH"

TOMCAT_USER=tomcat$TOM_VERSION
TOMCAT_CONF=/etc/$TOMCAT_USER
TOMCAT_WEBAPPS=/var/lib/$TOMCAT_USER/webapps
TOMCAT_GRP=$TOMCAT_USER

DSPACE_INSTALLATION_DIRECTORY=/installations/dspace/dspace-orig-${REPO_BRANCH}
DSPACE_BASE_CONFIG_DIRECTORY=/home/vagrant/Projects/lindat-repo-configs


echo "DSpace setup"

echo "Creating links to webapplication"
sudo chown -R $TOMCAT_USER:$TOMCAT_USER /installations 
if [ ! -f $TOMCAT_WEBAPPS/oai ]; then
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/oai $TOMCAT_WEBAPPS/oai 
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/solr $TOMCAT_WEBAPPS/solr
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/xmlui $TOMCAT_WEBAPPS/xmlui
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/jspui $TOMCAT_WEBAPPS/jspui
fi
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_WEBAPPS/ 

echo "Making solr visible from outside"
# replace the first occurence of /* which is the LocalHost filter and do it in-place
sudo sed -r -i.bak "0,/>\/\*/s/>\/\*/>\/NOTEXISTING1\*/" $TOMCAT_WEBAPPS/solr/WEB-INF/web.xml

sudo service $TOMCAT_USER restart