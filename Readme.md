# Creates VM, Images ... with Packer 

Focus on supporting proxy.

## Images

All images have: 
- proxy suport except when the name ends with "-np" (*n*o *p*roxy).
- VirtualBox Guest Additions

WORKING:
- vb-fedora-24 VirtualBox (Oracle repo)  Fedora 24 
- vbrpmfusion-fedora-24 VirtualBox (RPMFusion repo)  Fedora 24 
-

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
-

## Install
### Pre-requisite
 
- VirtualBox v4.3.20 +
- Packer v0.7.5 +
- setup the proxy in all files: use the script `proxy-cleaner.sh`.
 
### Build the VM
 
Simply run `./make.sh *file.json*`. (It can take hours.)
And then `./launch.sh *file.json*`

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


