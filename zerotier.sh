#!/bin/bash

# ZeroTier 配置
NETWORK_ID="4d68e88fdeab3ba0"

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

# 卸载 ZeroTier，并重启系统
uninstall_zerotier() {
    echo "卸载 ZeroTier..."
    sudo systemctl stop zerotier-one
    sudo systemctl disable zerotier-one
    sudo zerotier-cli leave "$NETWORK_ID"
    sudo yum remove -y zerotier-one
    sudo rm -rf /var/lib/zerotier-one

    echo "ZeroTier 已卸载完成，系统将在 5 秒后重启..."
    sleep 5
    sudo reboot
}

# 主逻辑
case "$1" in
    install)
        install_zerotier
        ;;
    uninstall)
        uninstall_zerotier
        ;;
    *)
        echo "用法: $0 {install|uninstall}"
        exit 1
        ;;
esac
