#!/bin/bash

NETWORK_ID="e046e539715c73ae"
PLANET_URL="https://ghfast.top/https://github.com/4D4937/Others/raw/refs/heads/master/planet"

# Install ZeroTier and replace planet file
install_zerotier() {
    echo "Installing ZeroTier..."
    curl -s https://install.zerotier.com | sudo bash

    echo "Downloading and replacing planet file..."
    sudo curl -s -o /var/lib/zerotier-one/planet "$PLANET_URL"
    sudo chmod 644 /var/lib/zerotier-one/planet

    echo "Starting ZeroTier service..."
    sudo systemctl enable zerotier-one
    sudo systemctl start zerotier-one

    echo "Joining ZeroTier network: $NETWORK_ID"
    sudo zerotier-cli join "$NETWORK_ID"

    echo "Waiting for network initialization..."
    sleep 5

    echo "Current network status:"
    sudo zerotier-cli listnetworks
}

# Leave and rejoin network
rejoin_zerotier() {
    echo "Leaving ZeroTier network: $NETWORK_ID"
    sudo zerotier-cli leave "$NETWORK_ID"

    echo "Waiting for network status update..."
    sleep 3

    echo "Rejoining ZeroTier network: $NETWORK_ID"
    sudo zerotier-cli join "$NETWORK_ID"

    echo "Waiting for network initialization..."
    sleep 5

    echo "Current network status:"
    sudo zerotier-cli listnetworks
}

# Uninstall ZeroTier
uninstall_zerotier() {
    echo "Stopping ZeroTier service..."
    sudo systemctl stop zerotier-one
    sudo systemctl disable zerotier-one

    echo "Leaving ZeroTier network: $NETWORK_ID"
    sudo zerotier-cli leave "$NETWORK_ID"

    echo "Uninstalling ZeroTier..."
    sudo yum remove -y zerotier-one

    echo "Cleaning up residual files..."
    sudo rm -rf /var/lib/zerotier-one

    echo "ZeroTier uninstalled"
    reboot
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
