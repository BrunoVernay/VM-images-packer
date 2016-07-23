# SELinux for the Network:
sudo setsebool httpd_can_network_relay=1
sudo setsebool httpd_can_network_connect=1

# Also depending on you config (or only allow from interface vboxnet0)
sudo firewall-cmd --zone=internal --change-interface=vboxnet0
sudo firewall-cmd --zone=internal --add-service=http
sudo firewall-cmd --zone=internal --add-service=squid

sudo systemctl restart squid httpd

