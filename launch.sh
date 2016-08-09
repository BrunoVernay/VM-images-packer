#!/bin/bash

# Launch the VM.
#  and show IP address to use for SSH access

export VM_NAME="${1%.json}"

echo "Shuting down eventually ..."
VBoxManage controlvm $VM_NAME acpipowerbutton   # poweroff
until $(VBoxManage showvminfo --machinereadable $VM_NAME | grep -q ^VMState=.poweroff.)
do
   sleep 1
done

VBoxManage startvm $VM_NAME  --type headless

#vboxmanage showvminfo $VM_NAME --details
#VBoxManage guestproperty enumerate $VM_NAME
export VM_IP=$(vboxmanage guestproperty wait $VM_NAME "/VirtualBox/GuestInfo/Net/1/V4/IP" --timeout 25000 | sed -n "s/.* \([0-9\.]*\), .*/\1/gp")

echo "VM_IP: $VM_IP"

# We could even launch SSH at this stage, since ssh_config knows what to do for 192.168.56.*
sleep 2
ssh $VM_IP

