#!/bin/bash

# Launch the VM.
#  and show IP address to use for SSH access

export VM_NAME="${1%.json}"


VBoxManage startvm $VM_NAME    ## --type headless
sleep 12

#vboxmanage showvminfo $VM_NAME --details
#VBoxManage guestproperty enumerate $VM_NAME
vboxmanage guestproperty get $VM_NAME "/VirtualBox/GuestInfo/Net/0/V4/IP"
vboxmanage guestproperty get $VM_NAME "/VirtualBox/GuestInfo/Net/1/V4/IP"

# We could even launch SSH at this stage

