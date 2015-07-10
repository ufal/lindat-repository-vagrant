#!/bin/bash
#
# Setup LINDAT/CLARIN repository
# see http://lindat.cz
# Author(s): LINDAT/CLARIN dev team
#


# Import few communities
#

source /home/vagrant/Projects/variables.sh

OAI_ENDPOINT=https://lindat.mff.cuni.cz/repository/oai/request
METADATA_FORMAT=dim
IMPORT_DEF=$DSPACE_BASE_CONFIG_DIRECTORY/dspace-import-structure.xml
IMPORT_OUTPUT=/tmp/dspace-com.xml
# 1 - only metadata
IMPORT_TYPE=1
DSPACE_USER=dspace@lindat.cz 

# create collection/community 
echo "Creating communities and collections"
sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace structure-builder -f $IMPORT_DEF -o $IMPORT_OUTPUT -e $DSPACE_USER

COLLECTION_ID=`grep collection $IMPORT_OUTPUT | sed 's/.*collection\ identifier=\"\([^\"]*\)\".*/\1/g'`
echo "Harvesting $OAI_ENDPOINT into $COLLECTION_ID by $DSPACE_USER"
# set params
sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace harvest -s -c $COLLECTION_ID -t $IMPORT_TYPE -a $OAI_ENDPOINT -m $METADATA_FORMAT -i all
# remove all harvested
sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace harvest -P -e $DSPACE_USER
# harvest the selected one
sudo $DSPACE_INSTALLATION_DIRECTORY/bin/dspace harvest -r -e $DSPACE_USER -c $COLLECTION_ID
