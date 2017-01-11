#!/bin/bash

source /home/vagrant/Projects/variables.sh

#
#
#echo "===="
#echo "Making solr visible from outside"
cp $DSPACE_BASE_CONFIG_DIRECTORY/solr-web.xml $DSPACE_INSTALLATION_DIRECTORY/webapps/solr/WEB-INF/web.xml

# disable enforce https for rest
cp $DSPACE_BASE_CONFIG_DIRECTORY/rest-web.xml $DSPACE_INSTALLATION_DIRECTORY/webapps/rest/WEB-INF/web.xml




