#!/bin/sh

cd /root

# We need to configure puppet client because it needs pluginsync=true for stdlib
# plugin
cp /etc/puppet/puppet.conf backup.puppet.conf
#wget -O /etc/puppet/puppet.conf http://192.168.10.1/sunray-puppet-client.conf

# Download and set the rc.local (boot script) for the node
# so that puppet is run on boot
wget -O rc.local http://192.168.10.1/sunray-node-firstboot.sh
chmod +x rc.local
cp /etc/rc.local rc.local.backup
mv rc.local /etc/rc.local

# usefull
wget -O clean_puppet_cert http://192.168.10.1/sunray-puppet-clean.sh
chmod +x clean_puppet_cert

