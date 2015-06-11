#!/bin/bash

# Wait for network is up
echo -n "Waiting for network."
while ! ip addr show | grep -F "inet 192.168.10" >> /dev/null
do
  sleep 1
  echo -n "."
done

echo ""
echo ip addr show | grep -F "192.168.10"

# Check if this is the first time booting
if [ ! -f /root/puppet-node.log ]
then
    touch /root/puppet-node.log
    echo "First time booting" >> /root/puppet-node.log
    puppet agent --waitforcert --test  >> /root/puppet-node.log
    puppet agent --enable >> /root/puppet-node.log
fi

# Run puppet for node
echo "Running puppet..."
echo "boot $(date)" >> /root/puppet-node.log

puppet agent -t | while read line; do
    echo $line
    echo $line >> /root/puppet-node.log
done


# TODO tmp reaper
echo "Reaping scratch"

exit 0

