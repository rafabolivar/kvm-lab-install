#!/bin/bash

GREEN='\033[0;32m' # Green Color
NC='\033[0m' # No Color

echo "Updating System"
echo "---------------"

sudo apt-get -y update
sudo apt-get -y upgrade

echo "Installing Required Packages for KVM"
echo "------------------------------------"

sudo apt-get -y install qemu-kvm libvirt-daemon-system virtinst libvirt-clients bridge-utils genisoimage libguestfs-tools

echo "Enabling virtualization Services"
echo "--------------------------------"

sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER

echo "Installing Required Packages for Cockpit"
echo "----------------------------------------"

sudo apt-get -y install cockpit cockpit-machines
sudo systemctl start cockpit
sudo systemctl status cockpit

echo "Customizing qemu settings"
echo "-------------------------"
echo "security_driver = "'"none"'"" | sudo tee -a /etc/libvirt/qemu.conf

echo -e "Now you can access your Cockpit Server at ===> ${GREEN}https://`ip addr | grep eno1 | grep inet | awk {'print $2'} | awk -F/ {'print $1'}`:9090${NC}"
