#!/bin/bash
# Configure the Proxy

# CentOS 7 still does not use DNF
if [ -e /etc/dnf/dnf.conf ]; then
  sudo sh -c 'echo -e "proxy=FCKNG_HTTP_PROXY" >> /etc/dnf/dnf.conf'
fi

if [ -e /etc/yum.conf ]; then
  sudo sh -c 'echo -e "proxy=FCKNG_HTTP_PROXY" >> /etc/yum.conf'
fi


sudo sh -c 'cat > /etc/profile.d/proxy.sh <<EOM
export http_proxy=FCKNG_HTTP_PROXY
export https_proxy=FCKNG_HTTP_PROXY
EOM'
sudo chmod 0555 /etc/profile.d/proxy.sh

sudo sh -c 'cat > /etc/environment <<EOM
http_proxy="FCKNG_HTTP_PROXY"
https_proxy="FCKNG_HTTP_PROXY"
no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOM'
