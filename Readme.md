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
 
- VirtualBox v5.1.3 +
- Packer v0.7.5 +
- Eventually setup your corporate proxy in all files: use the script `proxy-cleaner.sh`.
- Setup your SSH key (or enable passwords) in the Packer file (.json) and the kickstart file
- Setup your local RPM cache (or change the kickstart file)
 
### All kind of proxy ...

I deal with 2 proxy:
- a corporate proxy (zScaler) to access Internet
- a local proxy (Squid) to speed-up repetitives downloads during the install only!

#### Corporate Proxy

I configure the Guest to use the Corporate proxy to access Internet.

See the script `proxy-cleaner.sh`

The proxy will be configured for DNF and as an environment variable. This is done in a shell provisioner.

Also do not forget to configure the local RPM cache (/etc/squid/squid.conf) to use the Corporate proxy.

#### Squid local RPM cache

To avoid repetitive downloads of the same RPM, I setup a local cache with Squid and Apache on my local laptop.

Once installed (see below), you can launch it with `rpm-cache/start.sh` I did not make it permanent, because I do not want to have Squid and Apache and security settings always on.
Your kickstart file must then use http://10.0.2.2/ or http://192.168.56.1/ depending on the interface setup in the packer template.

Inspiration:
- I mostly copied this https://www.berrange.com/posts/2015/12/09/setting-up-a-local-caching-proxy-for-fedora-yum-repositories/
- See also https://github.com/spacewalkproject/spacewalk/blob/master/proxy/installer/squid.conf
- General info (bit old and complicated): http://yum.baseurl.org/wiki/YumMultipleMachineCaching

An install script would looks like this (you may want to manually edit your squid config file):
```
sudo dnf install squid httpd

sudo cat >> /etc/squid/squid.conf <<EOF
# Uncomment the following 2 lines to use a Corporate proxy (see http://wiki.squid-cache.org/Features/CacheHierarchy)
#cache_peer Proxy.MyCorporate.net parent 80 0 no-query default login=YourLogin
#never_direct allow all
cache_replacement_policy heap LFUDA
maximum_object_size 8192 MB
cache_dir aufs /var/spool/squid 16000 16 256 max-size=8589934592
acl repomd url_regex /repomd\.xml$
cache deny repomd
EOF

sudo cat > /etc/httpd/conf.d/yumcache.conf <<EOF
ProxyPass /fedora/ http://dl.fedoraproject.org/pub/fedora/linux/
ProxyRemote * http://localhost:3128/
EOF

# You have to explicitly create the Squid folder or SELinux will not allow the Squid service to write them (Squid won't even start without)
sudo squid -z
```

### Build the VM
 
Simply run `./make.sh filexxx.json`. (It can take hours.)
And then `./launch.sh filexxx.json`

### Security
 
The proxy should not be asking for a password.  But in any case: Be careful not to commit your proxy password in the repository!

Check the SSH key in kickstart (public) and Packer json template (path to private)

You may add password in the kickstart for debugging.

## More install info
 
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


