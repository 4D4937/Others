#!/bin/bash
echo 'export MY_IP=$(ip -4 addr show ens33 | grep -Po "inet \K[\d.]+" | head -n 1)' >> ~/.bashrc
source ~/.bashrc
echo "MY_IP has been set to: $MY_IP"
