#!/bin/bash

# 菜单函数
show_menu() {
    echo "请选择要执行的操作:"
    echo "1) 更换软件源"
    echo "2) 更新 DNS"
    echo "3) 查看当前软件源"
    echo "4) 查看当前 DNS"
    echo "5) 退出"
}

# 更换软件源
change_sources() {
    echo "请选择要更换的软件源:"
    echo "1) 官方源"
    echo "2) 清华源"
    echo "3) 阿里源"
    echo "4) 阿里内网源"
    echo "5) 腾讯源"
    echo "6) 腾讯内网源"

    read -p "请输入你的选择 [1-6]: " source_choice

    # 选择源的映射
    declare -A sources=(
        [1]="deb https://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
            deb-src https://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware

            deb https://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src https://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware

            deb https://deb.debian.org/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src https://deb.debian.org/debian/ bookworm-backports main contrib non-free non-free-firmware

            deb https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware"
        [2]="deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
            deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
            
            deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
            
            deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
            
            deb https://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main contrib non-free non-free-firmware"
        [3]="deb https://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware
            deb-src https://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware
            
            deb https://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            
            deb https://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            
            deb https://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware"
        [4]="deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm main contrib non-free non-free-firmware
            deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm main contrib non-free non-free-firmware
            
            deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            
            deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            
            deb http://mirrors.cloud.aliyuncs.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src http://mirrors.cloud.aliyuncs.com/debian-security/ bookworm-security main contrib non-free non-free-firmware"
        [5]="deb https://mirrors.cloud.tencent.com/debian/ bookworm main contrib non-free non-free-firmware
            deb-src https://mirrors.cloud.tencent.com/debian/ bookworm main contrib non-free non-free-firmware
            
            deb https://mirrors.cloud.tencent.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src https://mirrors.cloud.tencent.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            
            deb https://mirrors.cloud.tencent.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src https://mirrors.cloud.tencent.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            
            deb https://mirrors.cloud.tencent.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src https://mirrors.cloud.tencent.com/debian-security/ bookworm-security main contrib non-free non-free-firmware"
        [6]="deb http://mirrors.tencentyun.com/debian/ bookworm main contrib non-free non-free-firmware
            deb-src http://mirrors.tencentyun.com/debian/ bookworm main contrib non-free non-free-firmware
            
            deb http://mirrors.tencentyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            deb-src http://mirrors.tencentyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware
            
            deb http://mirrors.tencentyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            deb-src http://mirrors.tencentyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware
            
            deb http://mirrors.tencentyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
            deb-src http://mirrors.tencentyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware"
    )

    # 验证用户选择的选项
    if [[ -z "${sources[$source_choice]}" ]]; then
        echo "无效的选择，请重新输入。"
        return
    fi

    echo "正在更换为 ${source_choice} 号源..."
    
    # 备份当前的 sources.list
    mv /etc/apt/sources.list /etc/apt/sources.list.old

    # 更换 sources.list
    echo "${sources[$source_choice]}" > /etc/apt/sources.list

    echo "软件源更换完成！"
}

# 更新 DNS
update_dns() {
    echo "正在更新 DNS 设置..."
    # 备份当前的 resolv.conf 文件
    mv /etc/resolv.conf /etc/resolv.conf.backup
    
    # 设置新的 DNS 服务器 (阿里 DNS 和 Google DNS)
    cat > /etc/resolv.conf << EOF
# 自定义 DNS 设置
nameserver 223.5.5.5    # 阿里 DNS
nameserver 223.6.6.6    # 阿里 DNS
nameserver 8.8.4.4       # Google DNS
EOF
    echo "DNS 更新完成！"
}

# 查看当前软件源
view_sources() {
    echo "当前的软件源如下:"
    cat /etc/apt/sources.list
}

# 查看当前 DNS
view_dns() {
    echo "当前的 DNS 设置如下:"
    cat /etc/resolv.conf
}

# 主循环
while true; do
    show_menu
    read -p "请输入你的选择 [1-5]: " choice
    case $choice in
        1)
            change_sources
            ;;
        2)
            update_dns
            ;;
        3)
            view_sources
            ;;
        4)
            view_dns
            ;;
        5)
            echo "正在退出..."
            exit 0
            ;;
        *)
            echo "无效的选择，请重新输入。"
            ;;
    esac
    echo "" # 额外的换行
done