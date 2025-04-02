#!/bin/bash

# 安装 ZeroTier
curl -s https://install.zerotier.com | sudo bash

# 启动 ZeroTier 服务
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

# 加入指定的 ZeroTier 网络
NETWORK_ID="6ab565387aed6259"
sudo zerotier-cli join $NETWORK_ID

# 检查是否成功加入网络
sleep 5
sudo zerotier-cli listnetworks
