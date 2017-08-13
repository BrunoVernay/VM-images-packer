#!/bin/bash

# Re-create the VM.
# Argument: file name   ( ${VM_NAME%.json} removes the extension if needed)

export VM_NAME=${1:-"vb-fedora-24"}
export VM_NAME=${VM_NAME%.json}

# Clean up old VM
VBoxManage controlvm $VM_NAME poweroff
VBoxManage unregistervm $VM_NAME --delete
rm -rf output-"$VM_NAME"/

# Create shared folder (If you change this path change also in Packer: .json)
sudo mkdir -p /mnt/guest_vm
sudo sh -c 'chown -R $SUDO_UID:$SUDO_GID /mnt/guest_vm'

# Check before starting all the work (require package "pykickstart")
for i in  kickstart/*.*; do ksvalidator "$i" || exit 1; done
ansible-playbook --syntax-check provisioners/ansible/*.yml || exit 1

# This is where I put all my VirtualBox machines
VIRTUALBOX_VM=~/VirtualBoxVM
PLOG=0
if [ $PLOG -eq 1 ]; then
    mkdir -p log
    TIMER=$(date +"%F_%Hh%M")
    export PACKER_LOG=1
    export PACKER_LOG_PATH="log/${TIMER}_packer.txt"
fi

# Create the VM
time packr build $VM_NAME.json 

if [ -f output-$VM_NAME/$VM_NAME.ovf ]; then
    [ $PLOG -eq 1 ] && cp output-$VM_NAME/$VM_NAME.ovf log/${TIMER}_${VM_NAME}.ovf

    VBoxManage import output-$VM_NAME/$VM_NAME.ovf

    [ $PLOG -eq 1 ] && cp "$VIRTUALBOX_VM/$VM_NAME/$VM_NAME.vbox" log/${TIMER}_${VM_NAME}.vbox
    echo "Now: launch.sh $VM_NAME"
    ./launch.sh $VM_NAME
fi


