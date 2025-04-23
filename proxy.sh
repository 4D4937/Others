#!/bin/bash

# 设置代理服务器地址和端口
PROXY_SERVER="192.168.13.60"
PROXY_PORT="7899"

# 检查是否具有管理员权限
if [[ $EUID -ne 0 ]]; then
   echo "此操作需要管理员权限，请使用 sudo 运行脚本"
   exit 1
fi

# 写入系统级配置文件 /etc/environment
cat >> /etc/environment << EOF
http_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
HTTP_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
https_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
HTTPS_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
no_proxy="localhost,127.0.0.1,::1"
NO_PROXY="localhost,127.0.0.1,::1"
EOF

# 应用当前会话的代理设置
export http_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTP_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export https_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTPS_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="localhost,127.0.0.1,::1"

# 显示当前代理设置
echo "代理已写入 /etc/environment，当前会话设置如下："
echo "HTTP_PROXY: $http_proxy"
echo "HTTPS_PROXY: $https_proxy"
echo "NO_PROXY: $no_proxy"
