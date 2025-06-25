#!/usr/bin/env bash
# ------------------------------------------------------------------
# 自动为给定域名生成 Nginx → Cloudflare Worker 反向代理 (HTTP/80 和 HTTPS/443)
# 用法:
#   sudo ./auto_cf_worker_proxy.sh example.com [https://your-worker.workers.dev] [email@example.com]
# ------------------------------------------------------------------
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <domain> [worker_url] [email_for_letsencrypt]"
    exit 1
fi

DOMAIN="$1"
WORKER_URL="${2:-https://${DOMAIN}.workers.dev}"
EMAIL="${3:-your-email@example.com}"

NGINX_CONF_DIR="/etc/nginx/conf.d"
CONF_FILE="${NGINX_CONF_DIR}/${DOMAIN}.conf"
SSL_CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"

# 检查 SSL 证书是否存在
if [ ! -d "$SSL_CERT_DIR" ]; then
    echo "SSL证书不存在，正在通过 Let's Encrypt 获取证书..."
    # 获取 SSL 证书，需安装 certbot
    sudo certbot --nginx -d ${DOMAIN} -m ${EMAIL} --agree-tos --non-interactive
fi

# 生成 Nginx 配置
sudo tee "${CONF_FILE}" >/dev/null <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    # HTTP 重定向到 HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }

    # 可选：对 ACME 等 HTTP-01 验证友好
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    # SSL 配置
    ssl_certificate ${SSL_CERT_DIR}/fullchain.pem;
    ssl_certificate_key ${SSL_CERT_DIR}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;

    # 主反向代理
    location / {
        # 1) 把上游域名单独存起来便于引用
        set \$upstream_host ${WORKER_URL#https://};

        # 2) 走 HTTPS 直连 Cloudflare Worker
        proxy_pass https://\$upstream_host;

        # --- 关键修正点 ---
        proxy_set_header Host \$upstream_host;    # Host 头改成 Worker 的域名
        proxy_ssl_server_name on;                # 开启 SNI
        proxy_ssl_name \$upstream_host;           # SNI 里填 Worker 域名
        # --------------------------------------

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_intercept_errors on;
    }

    # 如果没写过 resolver，可放在 http{} 或 server{} 顶层
    resolver 1.1.1.1 8.8.8.8 valid=300s;
}
EOF

# 校验并热重载
sudo nginx -t && sudo systemctl reload nginx

echo "✅ 已为 ${DOMAIN} 配置反向代理 → ${WORKER_URL}"
echo "   已为 ${DOMAIN} 配置 SSL 证书，并将 HTTP 重定向到 HTTPS。"
echo "   证书由 Let's Encrypt 提供，如需续期，请定期运行 certbot renew。"
