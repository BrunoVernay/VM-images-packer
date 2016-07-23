# Creates VM, Images ... with Packer 

Focus on supporting proxy.

## Images

All images have: 
- proxy support except when the name ends with "-np" (**n**o **p**roxy).
- VirtualBox Guest Additions

WORKING:
- vb-fedora-24 VirtualBox (Oracle repo)  Fedora 24 
- vbrpmfusion-fedora-24 VirtualBox (RPMFusion repo)  Fedora 24 


OBSOLETE:
- Ltib-0
- CentOS-\*

### SSH

Currently login is toto/toto 
TODO: use a key: ssh_key_path ssh_private_key_file

## Reproductible builds

The point is to script the build.
- Create the Virtual Machine
- Install the required packages

I will try to add:
- libvirt and some tinier images
- Ansible support (instead of Salt)
- make alternates to VirtualBox



## Install
### Pre-requisite
 
- VirtualBox v4.3.20 +
- Packer v0.7.5 +
- setup the proxy in all files: use the script `proxy-cleaner.sh`.
 
### All kind of proxy ...

I deal with 2 proxy:
- a corporate proxy (zScaler) to access Internet
- a local proxy (Squid) to speed-up repetitives downloads during the install only!

#### Corporate Proxy

I configure the Guest to use the Corporate proxy to access Internet.

See the script `proxy-cleaner.sh`

The proxy will be configured for DNF and as an environment variable. Look at the post installation in kickstart files.

TODO: Since the Installation itself does not use the corporate proxy anymore I could refactor to use a shell provisioner to setup the proxy.

#### Squid local RPM cache

To avoid repetitive downloads of the same RPM, I setup a local cache with Squid and Apache on my local laptop.

Inspiration:
- I mostly copied this https://www.berrange.com/posts/2015/12/09/setting-up-a-local-caching-proxy-for-fedora-yum-repositories/
- See also https://github.com/spacewalkproject/spacewalk/blob/master/proxy/installer/squid.conf
- General info (bit old and complicated): http://yum.baseurl.org/wiki/YumMultipleMachineCaching

I guess I should write a script, but the idea is:
```
sudo dnf install squid httpd

# cat >> /etc/squid/squid.conf <<EOF
cache_replacement_policy heap LFUDA
maximum_object_size 8192 MB
cache_dir aufs /var/spool/squid 16000 16 256 max-size=8589934592
acl repomd url_regex /repomd\.xml$
cache deny repomd
EOF

# cat > /etc/httpd/conf.d/yumcache.conf <<EOF
ProxyPass /fedora/ http://dl.fedoraproject.org/pub/fedora/linux/
ProxyPass /fedora-secondary/ http://dl.fedoraproject.org/pub/fedora-secondary/
ProxyRemote * http://localhost:3128/
EOF

# You have to explicitly create the Squid folder or SELinux will not allow the Squid service to write them (Squid won't even start without)
sudo squid -z

# SELinux for the Network:
sudo setsebool httpd_can_network_relay=1
sudo setsebool httpd_can_network_connect=1

# Also depending on you config (or only allow from interface vboxnet0)
sudo firewall-cmd --zone=internal --change-interface=vboxnet0
sudo firewall-cmd --zone=internal --add-service=http

sudo systemctl restart squid httpd
```

### Build the VM
 
Simply run `./make.sh filexxx.json`. (It can take hours.)
And then `./launch.sh filexxx.json`

## More install info
 
### Security
 
The proxy should not be asking for a password.  But in any case: Be careful not to commit your proxy password in the repository!


### Fedora

For usual stuff

### CentOS

For pro constraints

### Ubuntu

The supported version is Ubuntu 12.04 "Precise".  It *may* also work with more recent version.

We use a KickStart file to automate the installation.

Package installation is tricky (apt-get)

### Virtualbox

Useful command lines available: https://www.virtualbox.org/manual/ch08.html

You will have to change the name in the path to the VirtualBox guest addition `guest_additions_url`, in the `Ltib-0.json` file.
We could have use environment variables https://www.packer.io/docs/templates/user-variables.html or use the online file "http:// ...". But this is easier and more efficient.

We create a **shared folder** to ease exchanging files with the host. See files `make.sh` and `Ltib-0.json`.
On the host: `/mnt/ltib-vm` and on the guest: `/media/sf_LTIB`.


