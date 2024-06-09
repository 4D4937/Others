#!/bin/sh

# 更新包列表
apk update

# 安装所需软件包
apk add wget curl py3-cryptography python3 py3-pip

# 下载脚本文件
wget https://raw.githubusercontent.com/4D4937/Others/master/aes_crypto_tool.py

# 运行脚本文件
python3 aes_crypto_tool.py
