# Title: Arch-Linux-Cleanup-Script
# Author: Savin, V
# Date: 2023
# Code version: 1.0.1
# Type: source code
# Web address: https://github.com/pocket-red-fox
# License: MIT License
# 
# Copyright (c) 2023, Savin, V
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#!/bin/bash

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
