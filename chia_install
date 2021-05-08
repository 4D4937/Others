#!/bin/bash
apt-get upgrade -y
apt install git -y
git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules
cd chia-blockchain
sh install.sh

. ./activate
