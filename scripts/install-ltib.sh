
# Configure and copy LTIB related resources

echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
echo '%users ALL=NOPASSWD: /usr/bin/rpm/, /opt/freescale/ltib/usr/bin/rpm, /bin/rm' >> /etc/sudoers

update-alternatives --install /bin/sh sh /bin/bash 1

mkdir /opt/freescale


chown -R toto:users /opt/*


.

