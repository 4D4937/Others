#!/bin/bash

# ZeroTier Configuration
NETWORK_ID="5ef99e6bc234db30"
PLANET_URL="https://ghfast.top/https://github.com/4D4937/Others/raw/refs/heads/master/planet"

# Install ZeroTier and replace planet file
install_zerotier() {
    curl -s https://install.zerotier.com | sudo bash
    
    sudo wget -q -O /var/lib/zerotier-one/planet "$PLANET_URL" || { echo "Failed to download planet file"; exit 1; }
    echo "Planet file downloaded successfully"
    
    sudo chmod 644 /var/lib/zerotier-one/planet || { echo "Failed to set planet file permissions"; exit 1; }
    echo "Planet file permissions set successfully"
    
    sudo systemctl enable zerotier-one || { echo "Failed to enable ZeroTier service"; exit 1; }
    echo "ZeroTier service enabled successfully"
    
    sudo systemctl start zerotier-one || { echo "Failed to start ZeroTier service"; exit 1; }
    echo "ZeroTier service started successfully"
    
    sudo zerotier-cli join "$NETWORK_ID" || { echo "Failed to join network $NETWORK_ID"; exit 1; }
    echo "Successfully joined network $NETWORK_ID"
    
    sleep 5
    if sudo zerotier-cli listnetworks | grep -q "$NETWORK_ID.*OK"; then
        echo "Network $NETWORK_ID joined successfully with status OK"
    else
        echo "Failed to join network $NETWORK_ID or status is not OK"
        exit 1
    fi
}

# Leave and rejoin network
rejoin_zerotier() {
    sudo zerotier-cli leave "$NETWORK_ID" || { echo "Failed to leave network $NETWORK_ID"; exit 1; }
    echo "Successfully left network $NETWORK_ID"
    
    sleep 3
    sudo zerotier-cli join "$NETWORK_ID" || { echo "Failed to rejoin network $NETWORK_ID"; exit 1; }
    echo "Successfully rejoined network $NETWORK_ID"
    
    sleep 5
    if sudo zerotier-cli listnetworks | grep -q "$NETWORK_ID.*OK"; then
        echo "Network $NETWORK_ID rejoined successfully with status OK"
    else
        echo "Failed to rejoin network $NETWORK_ID or status is not OK"
        exit 1
    fi
}

# Uninstall ZeroTier
uninstall_zerotier() {
    sudo systemctl stop zerotier-one || { echo "Failed to stop ZeroTier service"; exit 1; }
    echo "ZeroTier service stopped successfully"
    
    sudo systemctl disable zerotier-one || { echo "Failed to disable ZeroTier service"; exit 1; }
    echo "ZeroTier service disabled successfully"
    
    sudo zerotier-cli leave "$NETWORK_ID" || { echo "Failed to leave network $NETWORK_ID"; exit 1; }
    echo "Successfully left network $NETWORK_ID"
    
    sudo yum remove -y zerotier-one || { echo "Failed to uninstall ZeroTier"; exit 1; }
    echo "ZeroTier uninstalled successfully"
    
    sudo rm -rf /var/lib/zerotier-one || { echo "Failed to clean up residual files"; exit 1; }
    echo "Residual files cleaned up successfully"
    
    read -p "Do you want to reboot the system? (y/n): " answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        reboot || { echo "Failed to reboot"; exit 1; }
    else
        echo "Reboot skipped. Please reboot manually later to ensure complete cleanup."
    fi
}

# Main logic
case "$1" in
    install)
        echo "Starting ZeroTier installation..."
        install_zerotier
        ;;
    rejoin)
        echo "Starting rejoin process..."
        rejoin_zerotier
        ;;
    uninstall)
        echo "Starting uninstallation..."
        uninstall_zerotier
        ;;
    *)
        echo "Usage: $0 {install|rejoin|uninstall}"
        exit 1
        ;;
esac
