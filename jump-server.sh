#!/bin/bash

# 跳板机配置变量
JUMPHOST_USER="zrh"
JUMPHOST_IP="your_jumphost_ip"  # 请替换为您的跳板机IP地址

# 检查命令行参数数量是否正确
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <主机名> <内网IP>"
    exit 1
fi

# 获取主机名和内网IP
HOSTNAME=$1
INTERNAL_IP=$2

# 生成SSH配置条目
CONFIG="
Host $HOSTNAME
    HostName $INTERNAL_IP
    User $JUMPHOST_USER
    ProxyJump $JUMPHOST_USER@$JUMPHOST_IP
"

# 指定SSH配置文件路径
CONFIG_FILE=~/.ssh/config

# 如果配置文件不存在，则创建并设置权限
if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

# 删除已有的同名Host条目（如果存在）
sed -i "/^Host $HOSTNAME$/,/^Host /d" "$CONFIG_FILE"

# 追加新的配置条目到文件
echo "$CONFIG" >> "$CONFIG_FILE"

# 提示用户配置已更新
echo "SSH配置已更新: $HOSTNAME -> $INTERNAL_IP via $JUMPHOST_USER@$JUMPHOST_IP"

# 提示用户使用ssh命令连接时手动输入密码
echo "请使用以下命令连接并手动输入密码: ssh $HOSTNAME"
