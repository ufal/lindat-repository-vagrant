#!/bin/bash
#
# Setup LINDAT/CLARIN repository
# see http://lindat.cz
# Author(s): LINDAT/CLARIN dev team
#
# dev wiki: http://svn.ms.mff.cuni.cz/redmine/projects/dspace-modifications/wiki
# installation wiki: http://svn.ms.mff.cuni.cz/redmine/projects/dspace-modifications/wiki/CompilationInstallation
#
# TODO: mod_jk + autocomplete url


VCS_BRANCH="-b $REPO_BRANCH"
# env TOM_VERSION passed from Vagrantfile -> puppet -> OS environment 
TOMCAT=tomcat$TOM_VERSION
TOMCAT_CONF=/etc/$TOMCAT
TOMCAT_WEBAPPS=/var/lib/$TOMCAT/webapps
TOMCAT_GRP=$TOMCAT

INSTITUTE=vagrant-test
DSPACE_INSTANCE_NAME=repository
DSPACE_SOURCE_DIRECTORY=/home/vagrant/Projects/lindat-repo-source
DSPACE_INSTALLATION_DIRECTORY=/installations/dspace/dspace-1.8.2
DSPACE_BASE_CONFIG_DIRECTORY=/home/vagrant/Projects/lindat-repo-configs

#
#

echo "======================================================================="
echo " "
echo "======================================================================="
echo "LINDAT/CLARIN setup"
echo "======================================================================="

echo "===="
echo "Downloading LINDAT/CLARIN sources ($REPO_BRANCH)"

if [ ! -d DSPACE_SOURCE_DIRECTORY/.git ]; then
    echo "Removing already existing source tree"
    sudo chmod -R 777 $DSPACE_SOURCE_DIRECTORY
    sudo rm -rf $DSPACE_SOURCE_DIRECTORY
fi
git clone $VCS_BRANCH https://svn.ms.mff.cuni.cz/repository/ufal_dl $DSPACE_SOURCE_DIRECTORY

echo "===="
echo "Copying LINDAT/CLARIN specific configuration from config directory"
cp $DSPACE_BASE_CONFIG_DIRECTORY/local.conf $DSPACE_SOURCE_DIRECTORY/config/local.conf
rm $DSPACE_SOURCE_DIRECTORY/scripts/variable
cp $DSPACE_BASE_CONFIG_DIRECTORY/variable $DSPACE_SOURCE_DIRECTORY/scripts/variable

#
#

echo "===="
echo "Creating local git repositories for configuration"
cd $TOMCAT_CONF && sudo git init .

#
#

echo "===="
echo "Creating dspace and utilities DB tables"

cd $DSPACE_SOURCE_DIRECTORY/scripts
make create_database

cd  $DSPACE_SOURCE_DIRECTORY/scripts
make create_utilities_database
make setup
make new_deploy

#
#

echo "===="
echo "Adding web application links to tomcat"
if [ ! -f $TOMCAT_WEBAPPS/oai ]; then
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/oai $TOMCAT_WEBAPPS/oai 
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/solr $TOMCAT_WEBAPPS/solr
    ln -s $DSPACE_INSTALLATION_DIRECTORY/webapps/xmlui $TOMCAT_WEBAPPS/xmlui
fi

# tomcat7 does not like our symlinks - hack it
echo "===="
echo "Tomcat7 does not like symlinks in webapps, copy our sole symlink"
cd $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat && sudo git checkout bootstrap3
sudo mv $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat-link
sudo mkdir $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat 
sudo cp -R $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat-link/* $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat


#
#
echo "===="
echo "Making solr visible from outside"
cp $DSPACE_BASE_CONFIG_DIRECTORY/solr-web.xml $TOMCAT_WEBAPPS/solr/WEB-INF/web.xml
sudo make grant_rights

# needed e.g., by tomcat-users (see lindat.pp)
# give time for webapps to initialise - we need them to be accessible below
echo "===="
echo "Restarting and waiting for 30 seconds"
sudo make restart
sleep 30


# hardcode this one - should be read from local.conf
# - use the output of "pg_dump -C XX" as the source sql file
#
 
echo "===="
echo "Trying to import DB dumps"

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/user.sql
DB="dspace-1.8.2"
if [ -f "$SQL" ]; then
    echo "===="
    echo "Importing User definition $SQL to $DB"
    sudo -u postgres psql $DB < $SQL
fi

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/dspace.sql
DB="dspace-1.8.2"
if [ -f "$SQL" ]; then
    echo "===="
    echo "Importing DSpace DB from $SQL to $DB"
    sudo -u postgres dropdb $DB
    sudo -u postgres createdb $DB
    sudo -u postgres psql $DB < $SQL
fi

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/utilities.sql
DB="dspace-utilities-1.8.2"
if [ -f "$SQL" ]; then
    echo "===="
    echo "Importing utilities DB from $SQL to $DB"
    sudo -u postgres dropdb $DB
    sudo -u postgres createdb $DB
    sudo -u postgres psql $DB < $SQL
fi


#
#

echo "===="
echo "Preparing dspace - solr, statistics, cron jobs, oai"
sudo make grant_rights
make init_statistics
make init_indicies
sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace update-discovery-index
make add_cronjobs
make update_oai
sudo make grant_rights

#
sudo updatedb
