#!/bin/bash

# Re-create the VM.
#  and show IP address to use for SSH access (if VBox extension are successfuly installed)
# Argument: file name   ( ${VM_NAME%.json} removes the extension if needed)

export VM_NAME=${1:-"Ltib-0"}
export VM_NAME=${VM_NAME%.json}

# Clean up old VM
VBoxManage controlvm $VM_NAME poweroff
VBoxManage unregistervm $VM_NAME --delete
rm -rf output-"$VM_NAME"/

# Create shared folder (If you change this path change also in Packer: Ltib-0.json
sudo mkdir -p /mnt/ltib-vm
sudo sh -c 'chmod -R $SUDO_UID:$SUDO_GID /mnt/ltib-vm'


VIRTUALBOX_VM=~/VirtualBoxVM
export PACKER_LOG=1
if [ $PACKER_LOG -eq 1 ]; then
    mkdir -p log
    TIMER=$(date +"%F_%Hh%M")
    export PACKER_LOG_PATH="log/${TIMER}_packer.txt"
fi

# Create the VM
time packr build $VM_NAME.json 

if [ -f output-$VM_NAME/$VM_NAME.ovf ]; then
    [ $PACKER_LOG -eq 1 ] && cp output-$VM_NAME/$VM_NAME.ovf log/${TIMER}_${VM_NAME}.ovf

    VBoxManage import output-$VM_NAME/$VM_NAME.ovf

    [ $PACKER_LOG -eq 1 ] && cp "$VIRTUALBOX_VM/$VM_NAME/$VM_NAME.vbox" log/${TIMER}_${VM_NAME}.vbox
    echo "Now you can do: launch.sh $VM_NAME"
fi


