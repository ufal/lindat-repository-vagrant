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
start=`date +%s`

source /home/vagrant/Projects/variables.sh

#
#

echo "======================================================================="
echo " "
echo "======================================================================="
echo "LINDAT/CLARIN setup"
echo "======================================================================="

echo "===="
echo "Downloading LINDAT/CLARIN sources ($REPO_BRANCH)"

if [ -d $DSPACE_SOURCE_DIRECTORY ]; then
    echo "Removing working directory"
    sudo rm -rf $DSPACE_SOURCE_DIRECTORY
fi

git clone $VCS_BRANCH https://github.com/ufal/lindat-dspace.git $DSPACE_SOURCE_DIRECTORY
pushd $DSPACE_SOURCE_DIRECTORY/utilities/project_helpers/
bash ./setup.sh $DSPACE_SOURCE_DIRECTORY/..
popd



echo "===="
echo "Copying LINDAT/CLARIN specific configuration from config directory"
cp $DSPACE_BASE_CONFIG_DIRECTORY/local.conf $DSPACE_SOURCE_DIRECTORY/local.properties
cp $DSPACE_BASE_CONFIG_DIRECTORY/variable.makefile $LINDAT_CONFIG_DIRECTORY
pushd $LINDAT_SCRIPTS_DIRECTORY && cp start_stack_example.old start_stack.sh && cp stop_stack_example.old stop_stack.sh && popd

#
#
echo "==="
echo "Install prerequisites libs"
pushd $LINDAT_SCRIPTS_DIRECTORY && bash setup.prerequisites.sh && popd

#
#

echo "===="
echo "Creating dspace and utilities databases"

export MAVEN_OPTS="-Xmx2g -Xms1g"
cd $LINDAT_SCRIPTS_DIRECTORY
make create_databases
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
sudo mv $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat-link
sudo mkdir $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat 
sudo cp -R $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat-link/* $TOMCAT_WEBAPPS/xmlui/themes/UFAL/lib/lindat


#
#
#echo "===="
#echo "Making solr visible from outside"
cp $DSPACE_BASE_CONFIG_DIRECTORY/solr-web.xml $TOMCAT_WEBAPPS/solr/WEB-INF/web.xml


# hardcode this one - should be read from local.conf
# - use the output of "pg_dump -C XX" as the source sql file
#
 
#
#
echo "===="
echo "Testing/creating dspace db"
$DSPACE_INSTALLATION_DIRECTORY/bin/dspace database migrate
#
#
echo "===="
echo "Creating administrator"
$DSPACE_INSTALLATION_DIRECTORY/bin/dspace create-administrator -e "dspace@lindat.cz" -f "Mr." -l "Lindat" -p "dspace" -c "en"
#
#


echo "===="
echo "Trying to import DB dumps"

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/user.sql
DB="lindat"
if [ -f "$SQL" ]; then
    echo "===="
    echo "Importing User definition $SQL to $DB"
    sudo -u postgres psql $DB < $SQL
fi

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/dspace.sql
DB="lindat"
if [ -f "$SQL" ]; then
    echo "===="
    echo "Importing DSpace DB from $SQL to $DB"
    sudo -u postgres dropdb $DB
    sudo -u postgres createdb $DB
    sudo -u postgres psql $DB < $SQL
fi

SQL=$DSPACE_BASE_CONFIG_DIRECTORY/../dumps/utilities.sql
DB="lindat-utilities"
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
#make init_statistics
#make init_indicies
#sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace update-discovery-index
#make add_cronjobs
#make update_oai
#sudo make grant_rights


echo "=========="
end=`date +%s`
echo "This script took $((end-start)) seconds"
echo "=========="

# needed e.g., by tomcat-users (see lindat.pp)
# give time for webapps to initialise - we need them to be accessible below
echo "===="
echo "Restarting and waiting for 30 seconds"
sudo make restart
sleep 30

#
sudo updatedb
