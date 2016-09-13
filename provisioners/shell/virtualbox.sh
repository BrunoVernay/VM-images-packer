#!/bin/bash
#
# From https://github.com/kaorimatz/packer-templates/blob/master/scripts/fedora/virtualbox.sh
#

set -e
set -x

#sudo dnf -y install bzip2 kernel-devel make dkms
#sudo dnf -y install dkms

# Uncomment this if you want to install Guest Additions with support for X
# sudo dnf -y install xorg-x11-server-Xorg

#sudo setenforce Permissive

sudo systemctl start dkms
sudo systemctl enable dkms

sudo mount -o loop,ro ~/VBoxGuestAdditions.iso /mnt/
sudo /mnt/VBoxLinuxAdditions.run || :
sudo umount /mnt/
rm -f ~/VBoxGuestAdditions.iso

