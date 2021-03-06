# Creates VM, Images ... with Packer 

Focus on supporting proxy. (But (un)commenting a few lines and you get non-proxied access)

## Images

All images have: 
- proxy support except when the name ends with "-np" (**n**o **p**roxy).
- VirtualBox Guest Additions
- Vagrant export as a bonus

- vb-fedora-27 (VirtualBox from Oracle repo)  Fedora 27 


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
- Packer v0.7.5 + (Renamed `packerio`! Installed in `/usr/local/bin` to be in the PATH)
- Eventually setup your corporate proxy in all files: use the script `proxy-cleaner.sh`.
- Setup your SSH key (`ssh-keygen -t ecdsa` or enable passwords) in the Packer file (.json) and the kickstart file, I also add the Vagrant user and key.
- Setup your local RPM cache (or change the kickstart file)

Could help: `sudo dnf install pykickstart ansible squid`

### All kind of proxy ...

I deal with 2 proxy:
- a corporate proxy (ex: zScaler) to access Internet
- a local proxy (Squid) to speed-up repetitives downloads during the install only!

If you don't need them, it is easy to change the kickstart file to link to non-proxied sources.

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

You may addi root password in the kickstart for debugging.


## Network

I setup 2 network interfaces: 
- one to access Internet (Eth0 enp0s3 DHCP 10.0.2.0/24 "NAT")
- one for the host to access the guest (Eth1 enp0s8 DHCP 192.168.56.[101-254] "Host-only")

Once the VirtualBox extension are installed, one can ask for the "Host-only" IP with VBoxManage tools and SSH to the box. (see the launch.sh script)

Beware that the VirtualBox `virtio` driver has good perfomance, but CentOS is not capable of using enp0s3 names with it. CentOs will fallback on eth0 names!! See https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec_Troubleshooting_Network_Device_Naming.html

## Disk

Usually, the default install is OK. You can let `autopart` in kickstart do its job.

But you may need a particular setup. Typically, OpenShift master (in my example) requires to have free space in the Volume Group (LVM). In this case, the kickstart contains specific instruction.

If you need 2 disks, it is difficult to automate reliably! Instructions are specific to VirtualBox (Packer does not help you here) and if you want to recover errors, you may need particular scripts (outside Packer). I decided to stop te complexity to just creating the second disk. In case of errors, you have to use the VirtualBox GUI "File/Virtual Media Manager". Or on the command line you could do 
```
vboxmanage list hdds
VBoxManage storageattach    <uuid|vmname>  --storagectl <name> --device <number>  --medium none # Eventually detach the disk
vboxmanage closemedium disk <uuid|filename> --delete  
```
Also note that the second disk will be created in the current folder as VDI, then exported in VirtualBox  as VMDK. 

## More install info

### OpenShift

OpenShift Origin : There is a Master machine and a Node machine.

They each use different disk setup to illustrate the possibilities. 

They use a static IP, so the VirtualBox addition could be avoided (it would speed up install and reduce the size). Actually, the kickstart file is almost suffisient. 

I tried to reduce the size of the Docker-Storage-Setup. But it is hard to go beyond 8Go. Maybe we need to play with parameters (DATA_SIZE, DATA_MINIMUM_SIZE ...)

Maybe I go too far with the kickstart file and an ansible or shell script would be more the right tool for the job. But currently, nothing too complex is done.

#### To improve 

To install OpenShift, you still have to distribute the key:
```
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
for i in 192.168.56.10 192.168.56.12;do ssh-copy-id root@$i;done
```
and this will require a password for root (look at the kickstart file). It should be possible to installl from the linux host machine so (since you already have an account ssh key.  I have to test if it works !!!

### Fedora

For usual stuff. There is a Vagrant export for Fedora.
On Linux I had to specify the provider on the command line:
`vagrant box up --provider virtualbox`

### OpenStack CentOS 7

OpenStack all-in-one (with RDO Packstack)
(The OpenStack install fails if there is a proxy.)

OpenStack is huge.

### Virtualbox
 
Useful command lines available: https://www.virtualbox.org/manual/ch08.html

We could create a **shared folder** to ease exchanging files with the host. See files `make.sh` and `filexxx.json`.
On the host: `/mnt/guest_vm` and on the guest: `/media/host_machine`.


