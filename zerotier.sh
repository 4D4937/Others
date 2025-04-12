#!/bin/bash

# ZeroTier 配置
NETWORK_ID="5ef99e6bc234db30"
PLANET_URL="https://ghfast.top/https://github.com/4D4937/Others/raw/refs/heads/master/planet"

# 安装 ZeroTier 并替换 planet 文件
install_zerotier() {
    echo "安装 ZeroTier..."
    curl -s https://install.zerotier.com | sudo bash

    echo "下载并替换 planet 文件..."
    sudo curl -s -o /var/lib/zerotier-one/planet "$PLANET_URL"
    sudo chmod 644 /var/lib/zerotier-one/planet

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

# 卸载 ZeroTier
uninstall_zerotier() {
    echo "停止 ZeroTier 服务..."
    sudo systemctl stop zerotier-one
    sudo systemctl disable zerotier-one

    echo "离开 ZeroTier 网络: $NETWORK_ID"
    sudo zerotier-cli leave "$NETWORK_ID"

    echo "卸载 ZeroTier..."
    sudo yum remove -y zerotier-one

    echo "清理残留文件..."
    sudo rm -rf /var/lib/zerotier-one

    echo "ZeroTier 已卸载"
}

# 主逻辑
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
        echo "用法: $0 {install|rejoin|uninstall}"
        exit 1
        ;;
esac
