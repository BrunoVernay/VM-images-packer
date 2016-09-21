#!/bin/bash
# Configure OpenStack  https://www.rdoproject.org/install/quickstart/ 

# Removing them in kickstart does not work (http://unix.stackexchange.com/questions/194672/kickstart-file-installer-is-ignoring-some-of-the-do-not-install-packages-fro)
sudo yum -y remove NetworkManager firewalld

sudo systemctl enable network

#for i in {1..50}; do ping -c1 www.google.com &> /dev/null && break; done
/usr/sbin/ip a
cat /etc/resolv.conf
#cat -lh /etc/

# Must be done in 2 steps: one is the repo, the second is the package
sudo yum install -y centos-release-openstack-mitaka 
sudo yum update -y
sudo yum install -y openstack-packstack

sudo packstack --allinone

