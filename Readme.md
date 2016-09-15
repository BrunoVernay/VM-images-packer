# Creates VM, Images ... with Packer 

Focus on supporting proxy.

## Images

All images have: 
- proxy support except when the name ends with "-np" (**n**o **p**roxy).
- VirtualBox Guest Additions

- vb-fedora-24 (VirtualBox from Oracle repo)  Fedora 24 
- vbrpmfusion-fedora-24 (VirtualBox from RPMFusion repo)  Fedora 24 


## Reproductible builds

The point is to script the build.
- Create the Virtual Machine
- Install the required packages

I will try to add:
- libvirt and some tinier images
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
- a corporate proxy (ex: zScaler) to access Internet
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

sudo cp rpm-cache/dnfcache.conf /etc/httpd/conf.d/

# You have to explicitly create the Squid folder or SELinux will not allow the Squid service to write them (Squid won't even start without)
sudo squid -z
```

### Build the VM
 
Simply run `./make.sh filexxx<.json>`. (It can take hours.)
And then `./launch.sh filexxx<.json>`

### Security
 
The proxy should not be asking for a password.  But in any case: Be careful not to commit your proxy password in the repository!

SELinux is enabled in the Guest. (There is one line to uncomment in the kickstart file to disable it)

Check the SSH key in kickstart (public) and Packer json template (path to private)

You may add password in the kickstart for debugging.


## Network

I setup 2 network interfaces: 
- one to access Internet (Eth0 DHCP 10.0.2.0/24 "NAT")
- one for the host to access the guest (Eth1 DHCP 192.168.56.[101-254] "Host-only")

Once the VirtualBox extension are installed, one can ask for the "Host-only" IP with VBoxManage tools and SSH to the box. (see the launch.sh script)

## More install info
 
### Fedora

For usual stuff

### CentOS

For pro constraints and OpenStack all-in-one (with RDO)

### Virtualbox

Useful command lines available: https://www.virtualbox.org/manual/ch08.html

We could create a **shared folder** to ease exchanging files with the host. See files `make.sh` and `filexxx.json`.
On the host: `/mnt/guest_vm` and on the guest: `/media/host_machine`.


