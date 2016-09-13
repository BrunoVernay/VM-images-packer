#!/bin/bash
# Configure OpenStack  https://www.rdoproject.org/install/quickstart/ 

# Removing them in kickstart does not work (http://unix.stackexchange.com/questions/194672/kickstart-file-installer-is-ignoring-some-of-the-do-not-install-packages-fro)
sudo yum -y remove NetworkManager firewalld

sudo systemctl enable network

sudo yum install -y centos-release-openstack-mitaka openstack-packstack

# command not found
#packstack --allinone

