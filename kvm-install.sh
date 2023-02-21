#!/bin/bash

GREEN='\033[0;32m' # Green Color
NC='\033[0m' # No Color

echo "Updating System"
echo "---------------"

sudo apt-get -y update
sudo apt-get -y upgrade

echo "Installing Required Packages for KVM"
echo "------------------------------------"

sudo apt-get -y install qemu-kvm libvirt-daemon-system virtinst libvirt-clients bridge-utils genisoimage

echo "Enabling virtualization Services"
echo "--------------------------------"

sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER

echo "Configuring Networking"
echo "----------------------"

cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.orig
echo "network:
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false

  bridges:
    br0:
      interfaces: [eno1]
      addresses:
      - 192.168.1.30/24
      mtu: 1500
      nameservers:
        addresses:
        - 1.1.1.1
        - 8.8.8.8
        search: []
      routes:
      - to: default
        via: 192.168.1.1
  version: 2" | sudo tee /etc/netplan/00-installer-config.yaml > /dev/null
  
sudo netplan generate
sudo netplan --debug apply
# bridge control
brctl show
# network control
networkctl
networkctl status br0
# ip list
ip a show br0
# show host routes
ip route
# show arp table (IP to MAC)
arp -n

echo "<network>
  <name>host-bridge</name>
  <forward mode="'"bridge"'"/>
  <bridge name="'"br0"'"/>
</network>" | sudo tee /tmp/host-bridge.xml > /dev/null

# create libvirt network using existing host bridge
virsh net-define /tmp/host-bridge.xml
virsh net-start host-bridge
virsh net-autostart host-bridge

# state should be active, autostart, and persistent
virsh net-list --all

echo "Installing Required Packages for Cockpit"
echo "----------------------------------------"

sudo apt-get -y install cockpit cockpit-machines
sudo systemctl start cockpit
sudo systemctl status cockpit

echo -e "Now you can access your Cockpit Server at ===> ${GREEN}https://`ip addr | grep eno1 | grep inet | awk {'print $2'} | awk -F/ {'print $1'}`:9090${NC}"
