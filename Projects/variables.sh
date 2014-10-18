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
DSPACE_SOURCE_DIRECTORY=/home/vagrant/lindat-repo-source
DSPACE_INSTALLATION_DIRECTORY=/installations/dspace/dspace-1.8.2
DSPACE_BASE_CONFIG_DIRECTORY=/home/vagrant/Projects/lindat-repo-configs

DSPACE_USER=dspace@lindat.cz 
