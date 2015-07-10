#!/bin/bash

source /home/vagrant/Projects/variables.sh

cd $DSPACE_SOURCE_DIRECTORY/../scripts
sudo time make deploy_guru
sudo make restart