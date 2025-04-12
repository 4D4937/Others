#!/bin/bash

# ZeroTier 配置
NETWORK_ID="4d68e88fdeab3ba0"

# 安装 ZeroTier
install_zerotier() {
    echo "安装 ZeroTier..."
    curl -s https://install.zerotier.com | bash

    echo "加入 ZeroTier 网络: $NETWORK_ID"
    zerotier-cli join "$NETWORK_ID"

    echo "等待网络连接初始化..."
    sleep 5

    echo "当前网络状态:"
    zerotier-cli listnetworks
}

# 主逻辑
install_zerotier
