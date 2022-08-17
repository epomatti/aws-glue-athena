#!/usr/bin/env bash

# Update & Upgrade
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# MySQL
sudo apt-get install mysql-client -y

# Restart for Dist upgrades
sudo shutdown -r now