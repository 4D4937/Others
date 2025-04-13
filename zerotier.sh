#!/bin/bash

# ZeroTier Configuration
NETWORK_ID="5ef99e6bc234db30"
PLANET_URL="https://ghfast.top/https://github.com/4D4937/Others/raw/refs/heads/master/planet"

# Install ZeroTier and replace planet file
install_zerotier() {
    curl -s https://y.demo.lhyang.org/https://install.zerotier.com | sudo bash || { echo "Failed to install ZeroTier"; exit 1; }
    sudo curl -s -o /var/lib/zerotier-one/planet "$PLANET_URL" || { echo "Failed to download planet file"; exit 1; }
    sudo chmod 644 /var/lib/zerotier-one/planet || { echo "Failed to set planet file permissions"; exit 1; }
    sudo systemctl enable zerotier-one || { echo "Failed to enable ZeroTier service"; exit 1; }
    sudo systemctl start zerotier-one || { echo "Failed to start ZeroTier service"; exit 1; }
    sudo zerotier-cli join "$NETWORK_ID" || { echo "Failed to join network $NETWORK_ID"; exit 1; }
    sleep 5
    sudo zerotier-cli listnetworks || { echo "Failed to retrieve network status"; exit 1; }
}

# Leave and rejoin network
rejoin_zerotier() {
    sudo zerotier-cli leave "$NETWORK_ID" || { echo "Failed to leave network $NETWORK_ID"; exit 1; }
    sleep 3
    sudo zerotier-cli join "$NETWORK_ID" || { echo "Failed to rejoin network $NETWORK_ID"; exit 1; }
    sleep 5
    sudo zerotier-cli listnetworks || { echo "Failed to retrieve network status"; exit 1; }
}

# Uninstall ZeroTier
uninstall_zerotier() {
    sudo systemctl stop zerotier-one || { echo "Failed to stop ZeroTier service"; exit 1; }
    sudo systemctl disable zerotier-one || { echo "Failed to disable ZeroTier service"; exit 1; }
    sudo zerotier-cli leave "$NETWORK_ID" || { echo "Failed to leave network $NETWORK_ID"; exit 1; }
    sudo yum remove -y zerotier-one || { echo "Failed to uninstall ZeroTier"; exit 1; }
    sudo rm -rf /var/lib/zerotier-one || { echo "Failed to clean up residual files"; exit 1; }
    read -p "Do you want to reboot the system? (y/n): " answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        reboot || { echo "Failed to reboot"; exit 1; }
    fi
}

# Main logic
case "$1" in
    install)
        install_zerotier
        ;;
    rejoin)
        rejoin_zerotier
        ;;
    uninstall)
        uninstall_zerotier
        ;;
    *)
        echo "Usage: $0 {install|rejoin|uninstall}"
        exit 1
        ;;
esac
