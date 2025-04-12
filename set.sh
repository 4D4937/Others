#!/bin/bash

# 配置 YUM 源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
echo "YUM 源配置完成"

# 更新系统并安装必要的软件包
yum -y update
yum -y install network-scripts lrzsz tree net-tools ntpdate wget zip

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
echo "防火墙已关闭"

# 关闭 SELinux
# sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
# setenforce 0
# echo "SELinux 已关闭"

# 配置定时同步时间
echo "*/15 * * * * root /usr/sbin/ntpdate ntp1.aliyun.com &>/dev/null" >> /etc/crontab
systemctl restart crond
echo "时间同步任务已配置"

# 重启服务器
# reboot
