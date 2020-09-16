# Create a VM on a Linux server

This is a script to create and run a VM on an Ubuntu Server with no GUI access.
The script can be minimally modified to run on other Linux Servers by changing
the dpkg repo manager commands to install Virtual Box.

`sudo` is required to install the Virtual Box package but not thereafter. If
you have virtualbox package already installed you can run this script without
`sudo` privileges.

Run the script by `./create.sh` and follow the steps provided in the script.

You can learn more about vboxmanage commands from
https://www.virtualbox.org/manual/ch08.html#vboxmanage-intro

A decent chunk of the script was adopted from https://www.andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/.

## Known Issues

1. If you are behind a proxy server, make sure the host server can access to the
internet for installations. During Ubuntu Server setup, you might be asked to
provide proxy info, please leave it blank if your installation fails. It can be
set post installation.

2. After installation, check if you can access the internet by performing an
update -- `sudo apt update` for Ubuntu machines. 

For Servers:
If you cannot, then try setting appropriate proxy settings in the 
~/.bash_profile and add the following lines to a new file 95proxies 
created at `/etc/apt/apt.conf.d/`.
```
Acquire::http::proxy "proxy-ip:port";
Acquire::ftp::proxy "proxy-ip:port";
Acquire::https::proxy "proxy-ip:port";
```
Save and restart the VM to check internet access.

For Desktops:
If you cannot, then set the proxies appropriately in the
`Settings->Netowrk->Proxy` by changing it to `Manual`.

3. Check time, date and timezone. It can cause issues sometimes. If not set, set
it by using `timedatectl` commands. For desktops, you can set the time from GUI
Settings page.

4. To enable ssh access to the VM, install `openssh-server` and allow ssh
connections by `sudo ufw allow ssh`. After this, create a iptables rule to
forward ssh commands from a specific port on host server to port 22 of the VM.
`vboxmanage controlvm <vmname> natpf1 "ssh, tcp,
127.0.0.1, <port_num>, <vm-ip>, 22"`. Now, you can access the VM by `ssh
    user@127.0.0.1:<port_num>`. The `vm-ip` is usually 10.0.2.15 for the VMs.

