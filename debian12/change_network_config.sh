#!/bin/bash

echo "快速修改ip、网关、子关掩码；请注意修改配置"

# 定义网络接口名称
INTERFACE="ens18"

# 定义新的IP地址、子网掩码和网关
NEW_IP="192.168.31.76"
NEW_NETMASK="255.255.255.0"
NEW_GATEWAY="192.168.31.97"

echo "开始修改网络配置"

# 备份当前的网络配置文件
cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d%H%M%S)

# 修改网络配置文件
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $INTERFACE
iface $INTERFACE inet static
    address $NEW_IP
    netmask $NEW_NETMASK
    gateway $NEW_GATEWAY
EOF

# 重启网络服务以应用更改
systemctl restart networking

echo "网络配置已更新并应用。"

echo "开始修改DNS"

cp  /etc/resolv.conf   /etc/resolv.confbak.$(date +%Y%m%d%H%M%S) #备份

cat <<EOF > /etc/resolv.conf
nameserver $NEW_GATEWAY
EOF

echo "修改DNS为网关"