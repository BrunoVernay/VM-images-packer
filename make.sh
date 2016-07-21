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


# Create the VM
time packr build $VM_NAME.json && VBoxManage import output-$VM_NAME/$VM_NAME.ovf

echo "Now you can do: launch.sh $VM_NAME"

