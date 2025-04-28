#!/bin/bash

# 配置 SSH 免密钥登录脚本

# 定义变量
PUBLIC_KEY_URL="https://raw.githubusercontent.com/4D4937/Others/refs/heads/master/id_rsa.pub"
PRIVATE_KEY_URL="https://raw.githubusercontent.com/4D4937/Others/refs/heads/master/id_rsa"
SSH_DIR="$HOME/.ssh"
PUBLIC_KEY_PATH="$SSH_DIR/id_rsa.pub"
PRIVATE_KEY_PATH="$SSH_DIR/id_rsa"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# 检查并创建 .ssh 目录
if [ ! -d "$SSH_DIR" ]; then
    echo "创建 .ssh 目录..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 下载公钥
echo "下载公钥..."
if curl -s "$PUBLIC_KEY_URL" -o "$PUBLIC_KEY_PATH"; then
    echo "公钥下载成功"
    chmod 644 "$PUBLIC_KEY_PATH"
else
    echo "公钥下载失败"
    exit 1
fi

# 下载私钥
echo "下载私钥..."
if curl -s "$PRIVATE_KEY_URL" -o "$PRIVATE_KEY_PATH"; then
    echo "私钥下载成功"
    chmod 600 "$PRIVATE_KEY_PATH"
else
    echo "私钥下载失败"
    exit 1
fi

# 将公钥添加到 authorized_keys
echo "配置 authorized_keys..."
if [ -f "$PUBLIC_KEY_PATH" ]; then
    cat "$PUBLIC_KEY_PATH" >> "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    echo "公钥已添加到 authorized_keys"
else
    echo "公钥文件不存在"
    exit 1
fi

# 检查 SSH 配置文件
SSH_CONFIG="$SSH_DIR/config"
if [ ! -f "$SSH_CONFIG" ]; then
    echo "创建 SSH 配置文件..."
    cat <<EOL > "$SSH_CONFIG"
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile $PRIVATE_KEY_PATH
EOL
    chmod 600 "$SSH_CONFIG"
    echo "SSH 配置文件已创建"
fi

echo "SSH 免密钥登录配置完成！"
