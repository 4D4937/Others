#!/bin/bash

# 更新系统并安装必要的软件包
yum -y install network-scripts lrzsz tree net-tools ntpdate wget zip

# 配置 YUM 源
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo

yum clean all
yum makecache

echo "YUM 源配置完成"

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
echo "防火墙已关闭"

# 关闭 SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
echo "SELinux 已关闭"

# 配置定时同步时间
echo "*/15 * * * * root /usr/sbin/ntpdate ntp1.aliyun.com &>/dev/null" >> /etc/crontab
systemctl restart crond
echo "时间同步任务已配置"

# 安装 ZeroTier
curl -s https://install.zerotier.com | sudo bash

# 启动并设置开机自启
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

echo "ZeroTier 已安装并启动"

# 加入 ZeroTier 网络
NETWORK_ID="6ab565387aed6259"
sudo zerotier-cli join $NETWORK_ID

# 等待 5 秒后检查网络状态
sleep 5
sudo zerotier-cli listnetworks

echo "ZeroTier 网络已加入"

# 重启服务器
reboot
