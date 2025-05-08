#!/bin/bash

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用root权限运行此脚本"
  exit 1
fi

# 默认配置
INTERFACE="ens33"  # 默认网络接口
NETMASK="255.255.255.0"  # 默认子网掩码
GATEWAY="10.0.0.2"  # 默认网关
DNS1="223.5.5.5"  # 默认DNS服务器

# 只需手动输入IP地址
read -p "请输入静态IP地址: " IP_ADDR
if [ -z "$IP_ADDR" ]; then
  echo "错误: IP地址不能为空"
  exit 1
fi

# 配置文件路径
CONFIG_FILE="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"

# 备份原配置文件
if [ -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
  echo "已备份原配置文件为 ${CONFIG_FILE}.bak"
fi

# 创建新的配置文件
cat > "$CONFIG_FILE" << EOF
TYPE="Ethernet"
BOOTPROTO="static"
NAME="$INTERFACE"
DEVICE="$INTERFACE"
ONBOOT="yes"
IPADDR="$IP_ADDR"
NETMASK="$NETMASK"
GATEWAY="$GATEWAY"
DNS1="$DNS1"
EOF

echo "网络配置已更新，使用以下配置:"
echo "IP地址: $IP_ADDR"
echo "子网掩码: $NETMASK"
echo "默认网关: $GATEWAY"
echo "主DNS: $DNS1"

# 重启网络服务
echo "重启网络服务..."
systemctl restart network

echo "IP配置完成，当前配置："
ip addr show $INTERFACE

exit 0
