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


LIBS_DIRECTORY=/home/vagrant/piwik 

sudo aptitude install php5-mysql
echo "extension=mysqli.so" >> /etc/php5/apache2/conf.d/pdo_mysql.ini
# install PDO
apache2ctl restart
cd $LIBS_DIRECTORY
wget -nv http://builds.piwik.org/piwik.zip
unzip piwik.zip > /dev/null
chown -R www-data:www-data $LIBS_DIRECTORY