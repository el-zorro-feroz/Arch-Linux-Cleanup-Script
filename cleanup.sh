#!/bin/bash

# Check for errors in the system log
sudo journalctl -p 3 -xb

# Update the package database and upgrade all installed packages
sudo pacman -Syu

# Clean up any orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Scan the system for viruses using ClamAV
sudo pacman -S clamav
sudo freshclam
sudo clamscan -r --bell --remove /

# Remove ClamAV and its configuration files
sudo pacman -Rs clamav
sudo rm -rf /var/lib/clamav/

# Set I/O scheduler to deadline
echo 'deadline' | sudo tee /sys/block/sda/queue/scheduler

# Disable unnecessary services and daemons
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable cups-browsed
sudo systemctl disable ModemManager
sudo systemctl disable NetworkManager-wait-online
sudo systemctl disable systemd-timesyncd
sudo systemctl disable tlp
sudo systemctl disable upower

# Use a faster DNS resolver
sudo pacman -S dnsmasq
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf
sudo systemctl enable dnsmasq

# Find the UUID of the swap partition
SWAP_UUID=$(sudo blkid | grep 'TYPE="swap"' | awk -F '"' '{print $2}')

# Enable compression for swap space
sudo sed -i "s/UUID=${SWAP_UUID} none swap defaults/UUID=${SWAP_UUID} none swap defaults,compress/g" /etc/fstab

# Activate swap compression changes 
sudo swapon -a

# Clean up temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -rf ~/.cache/*
