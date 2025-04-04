#!/bin/bash

# 安装 ZeroTier
curl -s https://install.zerotier.com | sudo bash

# 启动 ZeroTier 服务
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

# 使用 orbit 设置节点
IDENTITY="b88b96282a"
sudo zerotier-cli orbit $IDENTITY $IDENTITY

# 加入指定的 ZeroTier 网络
NETWORK_ID="6ab565387aed6259"
sudo zerotier-cli join $NETWORK_ID

# 等待网络连接初始化
sleep 5

# 检查是否成功加入网络
sudo zerotier-cli listnetworks
