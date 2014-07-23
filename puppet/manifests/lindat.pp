#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#

####################################
# for java 8 do this
#echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
#apt-get update
#apt-get install oracle-java8-installer
#apt-get install oracle-java8-set-default
# add  /usr/lib/jvm/java-8-oracle/ to JDK_DIR in /etc/init.d/tomcat7
# update ecj.jar http://archive.eclipse.org/eclipse/downloads/drops4/R-4.2.1-201209141800/download.php?dropFile=ecj-4.2.1.jar
####################################


group { 'puppet': 
    ensure => present 
}
Exec { 
    path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] 
}
File { 
    owner => 0, group => 0, mode => 0644 
}

# do the hard work in the common package
import "common"

# LINDAT/CLARIN installation is done by a shell script, see Vagrant file
# Projects/setup.lindat.sh