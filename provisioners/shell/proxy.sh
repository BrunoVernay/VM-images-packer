#!/bin/bash
# Configure the Proxy

sudo sh -c 'echo -e "proxy=FCKNG_HTTP_PROXY" >> /etc/dnf/dnf.conf'

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
