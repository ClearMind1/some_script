#!/bin/bash

# 备份当前的 resolv.conf 文件
mv /etc/resolv.conf /etc/resolv.conf.backup

# 设置新的 DNS 服务器
cat > /etc/resolv.conf << EOF
# Custom DNS settings
nameserver 223.5.5.5    # 阿里 DNS
nameserver 223.6.6.6    # 阿里 DNS
nameserver 8.8.4.4    # Google DNS
# Add more nameservers if needed
EOF

# 输出成功消息
echo "DNS 修改成功，当前配置为:"
cat /etc/resolv.conf