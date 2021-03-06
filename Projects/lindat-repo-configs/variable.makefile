# Makefile for this project
# by LINDAT/CLARIN dev team
#
# Note: If you want to change this file, copy it to project/config
# 

# lindat-common settings
DIR_LINDAT_COMMON_THEME :=/opt/lindat-common
URL_LINDAT_COMMON_GIT   :=https://github.com/ufal/lindat-common.git
LINDAT_COMMON_THEME_FETCH=git fetch && git checkout -f releases && git pull

# tomcat
TOMCAT_VERSION=8
TOMCAT_USER:=tomcat$(TOMCAT_VERSION)
TOMCAT_GROUP:=tomcat$(TOMCAT_VERSION)
TOMCAT_CONF:=/etc/$(TOMCAT_USER)

# dspace
DSPACE_USER:=dspace

# tool directories
DIRECTORY_POSTGRESQL:=/var/lib/postgresql
BACKUP2l:=/usr/sbin/backup2l

# database settings - mostly for recovering 
RESTORE_FROM_DATABASE=prod-dspace


# you can use different versions e.g., export pg_dump=pg_dump --cluster
export pg_dump=pg_dump
