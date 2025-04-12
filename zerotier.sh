#!/bin/bash

# ZeroTier 配置
NETWORK_ID="5ef99e6bc234db30"

# 安装 ZeroTier
install_zerotier() {
    echo "安装 ZeroTier..."
    curl -s https://install.zerotier.com | sudo bash

    echo "启动 ZeroTier 服务..."
    sudo systemctl enable zerotier-one
    sudo systemctl start zerotier-one

    echo "加入 ZeroTier 网络: $NETWORK_ID"
    sudo zerotier-cli join "$NETWORK_ID"

    echo "等待网络连接初始化..."
    sleep 5

    echo "当前网络状态:"
    sudo zerotier-cli listnetworks
}

# 离开网络并重新加入
rejoin_zerotier() {
    echo "离开 ZeroTier 网络: $NETWORK_ID"
    sudo zerotier-cli leave "$NETWORK_ID"

    echo "等待网络状态更新..."
    sleep 3

    echo "重新加入 ZeroTier 网络: $NETWORK_ID"
    sudo zerotier-cli join "$NETWORK_ID"

    echo "等待网络连接初始化..."
    sleep 5

    echo "当前网络状态:"
    sudo zerotier-cli listnetworks
}

# 主逻辑
case "$1" in
    install)
        install_zerotier
        ;;
    rejoin)
        rejoin_zerotier
        ;;
    *)
        echo "用法: $0 {install|rejoin}"
        exit 1
        ;;
esac
