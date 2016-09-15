#!/bin/bash
# Configure OpenStack  https://www.rdoproject.org/install/quickstart/ 

# Removing them in kickstart does not work (http://unix.stackexchange.com/questions/194672/kickstart-file-installer-is-ignoring-some-of-the-do-not-install-packages-fro)
sudo yum -y remove NetworkManager firewalld

sudo systemctl enable network

# Must be done in 2 steps: one is the repo, the second is the package
sudo yum install -y centos-release-openstack-mitaka 
sudo yum update -y
sudo yum install -y openstack-packstack

# ip command not found (not in the PATH?)
#sudo packstack --allinone

