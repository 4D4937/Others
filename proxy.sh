#!/bin/bash

# 设置代理服务器地址和端口
PROXY_SERVER="192.168.31.51"
PROXY_PORT="7899"

# 写入用户级配置文件 ~/.bash_profile
cat >> ~/.bash_profile << EOF
export http_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTP_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export https_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTPS_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="localhost,127.0.0.1,::1"
EOF

# 应用当前会话的代理设置
export http_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTP_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export https_proxy="http://${PROXY_SERVER}:${PROXY_PORT}"
export HTTPS_PROXY="http://${PROXY_SERVER}:${PROXY_PORT}"
export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="localhost,127.0.0.1,::1"

# 显示当前代理设置
echo "代理已写入 ~/.bash_profile，当前会话设置如下："
echo "HTTP_PROXY: $http_proxy"
echo "HTTPS_PROXY: $https_proxy"
echo "NO_PROXY: $no_proxy"
