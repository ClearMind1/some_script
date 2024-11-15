#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志记录函数
log_action() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/system_config.log
}

# 检查是否以 root 权限运行
check_root() {
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}错误：此脚本需要以 root 权限运行${NC}" 
       exit 1
    fi
}
# 检查并安装 curl
install_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}未安装 curl，正在安装...${NC}"
        if apt-get update && apt-get install -y curl; then  # 使用 apt-get
            echo -e "${GREEN}curl 安装成功${NC}"
        else
            echo -e "${RED}curl 安装失败${NC}"
            exit 1
        fi
    fi
}

# 下载并安装 1Panel
install_1panel() {
    echo -e "${YELLOW}正在下载 1Panel 安装脚本...${NC}"
    if curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh; then
        echo -e "${GREEN}1Panel 安装脚本下载完成${NC}"
        echo -e "${YELLOW}正在执行 1Panel 安装脚本...(完成后将删除脚本)${NC}"
        bash quick_start.sh
        rm quick_start.sh  # 安装完成后删除脚本
    else
        echo -e "${RED}1Panel 安装脚本下载失败${NC}"
        exit 1
    fi
}
# 菜单函数
show_menu() {
    echo "请选择要执行的操作:"
    echo "1) 更换软件源"
    echo "2) 更新 DNS"
    echo "3) 查看当前软件源"
    echo "4) 查看当前 DNS"
    echo "5) 网络连接测试"
    echo "6) 安装 1Panel"  # 添加 1Panel 安装选项
    echo "7) 退出"
}


# 更换软件源
change_sources() {
    # 网络连接检查
    if ! ping -c 2 mirrors.tuna.tsinghua.edu.cn &> /dev/null; then
        echo -e "${RED}网络连接异常，无法更新软件源${NC}"
        return 1
    fi

    echo "请选择要更换的软件源:"
    echo "1) 官方源"
    echo "2) 清华源"
    echo "3) 阿里源"
    echo "4) 阿里内网源"
    echo "5) 腾讯源"
    echo "6) 腾讯内网源"
    
    read -p "请输入你的选择 [1-6]: " source_choice

    # 软件源映射
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

    # 输入验证
    if [[ ! "$source_choice" =~ ^[1-6]$ ]]; then
        echo -e "${RED}输入无效，请输入 1-6 之间的数字${NC}"
        return 1
    fi

    # 备份当前 sources.list
    if ! cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%Y%m%d_%H%M%S).bak; then
        echo -e "${RED}备份源文件失败${NC}"
        return 1
    fi

    # 写入新源
    echo "${sources[$source_choice]}" > /etc/apt/sources.list

    # 更新源缓存
    if apt-get update; then
        echo -e "${GREEN}软件源更新成功,请执行 apt update 更新${NC}"
        log_action "软件源更新成功"
    else
        echo -e "${RED}软件源更新失败${NC}"
        log_action "软件源更新失败"
    fi
}

# 更新 DNS
update_dns() {
    echo "选择 DNS 服务器:"
    echo "1) 阿里 DNS"
    echo "2) Google DNS"
    echo "3) Cloudflare DNS"
    echo "4) 自定义 DNS"

    read -p "请选择 [1-4]: " dns_choice

    case $dns_choice in
        1)
            DNS_SERVERS=("223.5.5.5" "223.6.6.6")
            ;;
        2)
            DNS_SERVERS=("8.8.8.8" "8.8.4.4")
            ;;
        3)
            DNS_SERVERS=("1.1.1.1" "1.0.0.1")
            ;;
        4)
            read -p "请输入自定义 DNS 服务器（用空格分隔）: " -a DNS_SERVERS
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            return 1
            ;;
    esac

    # 备份 resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.$(date +%Y%m%d_%H%M%S).bak

    # 写入 resolv.conf
    > /etc/resolv.conf
    for server in "${DNS_SERVERS[@]}"; do
        echo "nameserver $server" >> /etc/resolv.conf
    done

    echo -e "${GREEN}DNS 更新完成${NC}"
    log_action "DNS 更新完成"
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

# 网络连接测试
test_network() {
    echo "正在测试网络连接..."
    local test_sites=("www.baidu.com" "www.github.com"  "www.google.com")
    for site in "${test_sites[@]}"; do
        if ping -c 2 "$site" &> /dev/null; then
            echo -e "${GREEN}网络连接正常：$site${NC}"
        else
            echo -e "${RED}无法连接：$site${NC}"
        fi
    done
}

# 主程序
main() {
    # 检查 root 权限
    check_root

    # 主循环
    while true; do
        show_menu
        read -p "请输入你的选择 [1-7]: " choice
        
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
                test_network
                ;;
            6)  # 1Panel 安装
                install_curl
                install_1panel
                ;;
            7)
                echo "正在退出..."
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入。${NC}"
                ;;
        esac
        
        echo "" # 额外的换行
        read -p "按回车键继续..." # 暂停，方便查看输出
    done
}

# 运行主程序
main