#!/usr/bin/env bash

sudo swapoff /var/swap/swapfile
sudo fallocate -l 2G /var/swap/swapfile
sudo chmod 600 /var/swap/swapfile
sudo mkswap /var/swap/swapfile
sudo swapon /var/swap/swapfile

#echo '/var/swap/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
