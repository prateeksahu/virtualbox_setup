#!/bin/bash

# Install virtualbox if not installed
dpkg -s virtualbox &> /dev/null

if [ $? -eq 0 ]; then
  echo "VirtualBox is installed!"
else
  echo "Installing VirtualBox now. It will require sudo privilege."
  # Just the following line might work but out of the box, but approaching the
  # Oracle's official route
  # sudo apt install virtualbox virtualbox-ext-pack

  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | \
     sudo tee -a /etc/apt/sources.list.d/virtualbox.list
  sudo apt update
  sudo apt install virtualbox-6.1
  wget https://download.virtualbox.org/virtualbox/6.1.38/Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack
  sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack
  rm Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack
fi


# Referred from https://www.andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/
read -p "Name of the VM: " MACHINENAME
read -p "Allocated Memory for VM (in MB): " memory
read -p "Allocated CPU for VM: " cpu
read -p "Allocated Storage for VM (in MB): " hdd

read -p "Default installation is Ubuntu 20.04 64-bit Server VM. Type n|N if you wish to install a different OS. Return to continue: " default

if [[ $default = "n" ]] || [[ $default == "N" ]]; then
  read -p "Os type (along with architecture address width e.g. ubuntu_64 or windows_32): " ostype
  read -p "Desktop or Server image(desktop/server): " deployment
  read -p "ISO URL link: " url
else
  ostype='ubuntu_64'
  deployment='server'
  url=https://releases.ubuntu.com/focal/ubuntu-20.04.5-live-server-amd64.iso
fi

iso=${ostype}_${deployment}.iso

# Download debian.iso
if [ ! -f ~/Downloads/$iso ]; then
  cd ~/Downloads
  wget $url -O $iso
  cd -
fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype $ostype --register
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on --memory $memory --vram 128 --cpus $cpu --nic1 nat
#Create Disk and connect Iso
VBoxManage createhd --filename ~/VirtualBox\ VMs/$MACHINENAME/$MACHINENAME.vdi --size $hdd --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  ~/VirtualBox\ VMs/$MACHINENAME/$MACHINENAME.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium ~/Downloads/$iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

#Enable RDP
read -p "RDP port number (do not use an already used port): " port
IP=$(hostname -I)
VBoxManage modifyvm $MACHINENAME --vrde on --vrdeaddress $IP --vrdemulticon on --vrdeport $port
VBoxManage modifyvm $MACHINENAME --natpf1 "ssh, 0.0.0.0, 5001, 10.0.2.15, 22"
echo "Machine is starting, please open $IP:$port on any RDP tool to complete setup. Ctrl+C to close the VM."
echo "You can start the VM later by vboxmanage startvm $MACHINENAME --type headless or vboxheadless --startvm $MACHINENAME."
echo "You can powerdown a VM from CLI by vboxmanage --controlvm $MACHINENAME --poweroff"
#Start the VM
VBoxManage startvm $MACHINENAME --type headless
