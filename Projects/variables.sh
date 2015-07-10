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
DSPACE_SOURCE_DIRECTORY=/opt/lindat-dspace/sources/
LINDAT_SCRIPTS_DIRECTORY=/opt/lindat-dspace/sources/../scripts
LINDAT_CONFIG_DIRECTORY=/opt/lindat-dspace/sources/../config
DSPACE_INSTALLATION_DIRECTORY=/opt/lindat-dspace/installation/
DSPACE_BASE_CONFIG_DIRECTORY=/home/vagrant/Projects/lindat-repo-configs

DSPACE_USER=dspace@lindat.cz 
