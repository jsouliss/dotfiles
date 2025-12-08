#!/bin/bash

set -e # Exit on any errors

echo "[+] Starting installation"

# TODO Add Ubuntu packages
packages=(

)

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install "${packages[@]}"
sudo apt-get autoremove -y
sudo apt-get clean -y

echo "[+] Script completed"
