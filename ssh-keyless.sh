#!/bin/bash


SSH_DIR="$HOME/.ssh"
PUBLIC_KEY_PATH="$SSH_DIR/id_rsa.pub"
PRIVATE_KEY_PATH="$SSH_DIR/id_rsa"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SSH_CONFIG="$SSH_DIR/config"

# 你的公钥和私钥内容，注意首尾没有多余空格
PUB_KEY_CONTENT="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6BAbBzka0I4QnPb6+o6Z5/cpeD+ytkwR+1LNLW9Qv9U0BDm1/a/v/RVH1Zh4/go9bY6f8HPg4G7omUqeAzbm9ubz2FgEMvLBv8ZUM2CZG4+2lQ6D2gwmBf5KlWrd56VTAzqmWH+8ESQ1q/WQyp6ZwUUuwifDSDaFnSN8ASVfk6IqNMG+6YHbUSamamilf6UU/l+lC05TP1jCx4PFMMraGTqx+ptB3P1jDecxZli+dQO9BY/WVb3Ro91YXLdFlk5zPHrxiBvFFys3tJPe9eysd6AeyTA4cSXZEuI9geY8LjlvyDgUzwTXQMwSH7MU6Px/MpQyzMar8aRneR77hqHWx"
PRIV_KEY_CONTENT="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAugQGwc5GtCOEJz2+vqOmef3KXg/srZMEftSzS1vUL/VNAQ5t
f2v7/0VR9WYeP4KPW2On/Bz4OBu6JlKngM25vbm89hYBDLywb/GVDNgmRuPtpUOg
9oMJgX+SpVq3eelUwM6plh/vBEkNav1kMqemcFFLsInw0g2hZ0jfAElX5OiKjTBv
umB21EmpmpopX+lFP5fpQtOUz9YwseDxTDK2hk6sfqbQdz9Yw3nMWZYvnUDvQWP1
lW90aPdWFy3RZZOczx68YgbxRcrN7ST3vXsrHegHskwOHEl2RLiPYHmPC45b8g4F
M8E10DMEh+zFOj8fzKUMszGq/GkZ3ke+4ah1sQIDAQABAoIBAFynjMYUfVtVJYp2
UwCae13gcGCSBg4fYOncAMLUpsiMoyKXkSsbGpZ4bO6TQxXXbpjS9uW5eFpaVUqp
eQ3La215iwn4w+UYR7o610dikw5UkhbzrMWdV6rNZLpAiYuMEc9IIWjJ10CHMsvM
E5C3uUvQ8qaozu+SIodT4OA/qCw4XuF7lGsKDV9PZQpJ2Q/15L0LBtJUsqiM/tMR
s1dyISBY6NUsdeXSvhUD3MK/M9pdFjwgOeH05ashRjRD81PQOA2+2mSFsIF9ikNj
S+cueocSYOqPtGUhbFy1IzSSmSVZAtOXmGaQRSWjSjavvN7Gi8gHKAHo9DQrF9TN
Qp3uGAECgYEA4kmrJz2wMC/aOvX5yuCGcFuk2ibbB0+yXOExSogeRhoSJZ4QphcG
X+SFr0Kq/iIJ5kAOpt3txEIyRP2XzCSxdZe3MX224MMn7tsf4HvxaX8LEWqCMdb6
68HZfykTrAWjsDmtFhsxrwHGJ9hJZKetoNHb7pjdxeRtqbfp+eanV+ECgYEA0nCs
Gkqy6F5iCPbCKId8xJ5QEXuOHGgVNuiNuROGdbxuJJUyi7n2oMocCDV43YbAVNBY
7jWmVGXURSjwlc1jLHiQ2qLQctOFIsG8Mg6Ll/ts0apwL3xAIZDxsnEiNgZu221j
cYqcrB7Bz0axz3DyF3FWFpjsnM+21bDx1ZS0l9ECgYEAsx5lIDawVDRMpgc2puR7
Bk1EfHntPihTozmN7tU4QX05iBVKUG5BWX5mY4h+GZOQCnYCIwvgvU04xWuG0Mzq
u45QMBi2vcs8vNEutl7lhQBPHoYUcKcfD6buJr25GJ2OKFw/KhR0i3b4B2opDke8
JGR5lq/iPFbIh2NRDcMKC4ECgYBq7g+1aGGSS2s7LM+psnbGnb8HsyWZ75VgCjkB
Yxd+udmpwxok/8B/IVOvJCSfQ/p03k1h9WboGboLzmq5Y9zR2w2X2wVaY3qSF6le
Mh/igUJhI17P8i3QIIt/5ZbBpvErlGDkb89+cj5+6WguhTCukstwvhH0+GLqIHgx
09cUEQKBgED/z3qJxVELP+eMWFaTPCA8HuHvYj6qU7RqkwbgyL3rgOlWyEQObB9t
3EWwmEeVjdOxSYyqAZcbWOTT6dm0lAprVE7pZDzQ/9+yaJC5kxErSTrSY/RCU2NN
RfiTtyEkEAnoilH6NxzkKcFTM8CZD8o4H0J70PEHvwcik7oAgqJ/
-----END RSA PRIVATE KEY-----"

# 检查并创建 .ssh 目录
if [ ! -d "$SSH_DIR" ]; then
    echo "创建 .ssh 目录..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 写入公钥
echo "写入公钥..."
echo "$PUB_KEY_CONTENT" > "$PUBLIC_KEY_PATH"
chmod 644 "$PUBLIC_KEY_PATH"

# 写入私钥 （确保保留换行，否则 openssh 读取会报错！）
echo "写入私钥..."
printf "%s\n" "$PRIV_KEY_CONTENT" > "$PRIVATE_KEY_PATH"
chmod 600 "$PRIVATE_KEY_PATH"

# 写入 authorized_keys
echo "配置 authorized_keys..."
if ! grep -q "$PUB_KEY_CONTENT" "$AUTHORIZED_KEYS" 2>/dev/null; then
    echo "$PUB_KEY_CONTENT" >> "$AUTHORIZED_KEYS"
fi
chmod 600 "$AUTHORIZED_KEYS"

# 配置 SSH config
if [ ! -f "$SSH_CONFIG" ]; then
    echo "创建 SSH 配置文件..."
    cat <<EOL > "$SSH_CONFIG"
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile $PRIVATE_KEY_PATH
EOL
    chmod 600 "$SSH_CONFIG"
fi

echo "SSH 免密钥登录配置完成！"
