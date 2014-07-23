#!/bin/bash
#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#
# puppet dependency hell and more - instead of complicated setup let's move it here

echo "======================================================================="
echo " "
echo "======================================================================="
echo "Copying job definition to jenkins jobs directory and restarting jenkins"
echo "======================================================================="

JENKINSDIR=/var/lib/jenkins/jobs/lindat-redeploy
HOMEDIR=/home/vagrant/Projects/libs
 
sleep 10 
sudo mkdir -p $JENKINSDIR
sudo cp $HOMEDIR/config-jenkins-lindat-job.xml $JENKINSDIR/config.xml
sudo chown -R jenkins:jenkins $JENKINSDIR
sudo chmod -R 774 $JENKINSDIR
sudo service jenkins restart