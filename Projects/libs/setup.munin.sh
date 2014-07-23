#!/bin/bash
#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#
# do additional stuff mainly for postgresql 

echo "======================================================================="
echo " "
echo "======================================================================="
echo "Hacking munin"
echo "======================================================================="

munin-node-configure --suggest
munin-node-configure --shell
munin-node-configure --shell | grep "ln -s" | source /dev/stdin 
service munin-node restart
sudo -u munin /usr/bin/munin-cron