#!/bin/bash

# 检测操作系统
OS=$(cat /etc/os-release | grep -E "^ID=" | cut -d'=' -f2 | tr -d '"')

# 安装 s3cmd
install_s3cmd() {
    case $OS in
        "centos"|"rhel")
            # CentOS/RHEL 安装方法
            sudo yum install -y epel-release
            sudo yum install -y python3-pip s3cmd
            ;;
        "debian"|"ubuntu")
            # Debian/Ubuntu 安装方法
            sudo apt-get update
            sudo apt-get install -y s3cmd
            ;;
        *)
            echo "不支持的操作系统"
            exit 1
            ;;
    esac
}

# 配置 s3cmd（支持多云存储）
configure_s3cmd() {
    clear
    echo "选择云存储提供商："
    echo "1. 千牛云"
    echo "2. 阿里云OSS"
    echo "3. AWS S3"
    echo "4. 腾讯云COS"
    read -p "请选择 (1-4): " cloud_provider

    # 通用配置信息
    read -p "请输入 Access Key: " access_key
    read -sp "请输入 Secret Key: " secret_key
    echo

    # 根据不同云存储配置
    case $cloud_provider in
        1)  # 千牛云配置
            region="cn-east-1"
            endpoint="s3-${region}.qiniu.com"
            ;;
        2)  # 阿里云OSS配置
            read -p "请输入区域 (例如 oss-cn-hangzhou): " region
            endpoint="${region}.aliyuncs.com"
            ;;
        3)  # AWS S3配置
            read -p "请输入区域 (例如 us-east-1): " region
            endpoint="s3.${region}.amazonaws.com"
            ;;
        4)  # 腾讯云COS配置
            read -p "请输入区域 (例如 ap-beijing): " region
            endpoint="cos.${region}.myqcloud.com"
            ;;
        *)
            echo "无效选择"
            return 1
            ;;
    esac

    # 创建配置文件
    mkdir -p ~/.s3cfg
    cat > ~/.s3cfg << EOF
[default]
access_key = ${access_key}
secret_key = ${secret_key}
host_base = ${endpoint}
host_bucket = %(bucket)s.${endpoint}
use_https = True
signature_v2 = False
EOF

    echo "S3cmd 配置完成"
}

# 系统兼容性检查
system_check() {
   echo "系统诊断报告"
   echo "=============="

   # 系统基本信息
   echo "操作系统信息："
   cat /etc/os-release | grep -E "PRETTY_NAME|VERSION="

   # 硬件信息
   echo -e "\n硬件信息："
   # CPU信息
   echo "CPU:"
   cat /proc/cpuinfo | grep "model name" | head -n 1

   # 内存信息
   echo -e "\n内存:"
   free -h

   # 磁盘空间
   echo -e "\n磁盘空间:"
   df -h

   # Python 环境
   echo -e "\nPython 环境:"
   # 检查 Python 版本和路径
   which python3
   python3 --version

   # 网络诊断
   echo -e "\n网络诊断:"
   # 显示IP地址
   ip addr show | grep -E "inet "

   # 检查 s3cmd 是否已安装
   echo -e "\ns3cmd 状态:"
   if command -v s3cmd &> /dev/null; then
       s3cmd --version
   else
       echo "s3cmd 未安装"
   fi

   # 检查关键依赖
   echo -e "\n关键依赖检查:"
   dependencies=("python3" "pip" "curl" "wget")
   for dep in "${dependencies[@]}"; do
       if command -v "$dep" &> /dev/null; then
           echo "$dep: 已安装 ✓"
       else
           echo "$dep: 未安装 ✗"
       fi
   done

   # 系统安全和性能建议
   echo -e "\n系统建议:"
   # 检查系统更新
   if [[ "$OS" == "centos" || "$OS" == "rhel" ]]; then
       echo "检查系统更新: yum check-update"
       yum check-update || true
   elif [[ "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
       echo "检查系统更新: apt list --upgradable"
       apt list --upgradable || true
   fi
}

# 网络连接测试
test_network() {
    echo "正在测试网络连接..."

    # 测试常见对象存储域名
    local domains=(
        "s3.amazonaws.com"
        "oss-cn-hangzhou.aliyuncs.com"
        "cos.ap-beijing.myqcloud.com"
        "s3-cn-east-1.qiniu.com"
    )

    for domain in "${domains[@]}"; do
        if ping -c 4 "$domain" > /dev/null 2>&1; then
            echo "✓ $domain 网络连接正常"
        else
            echo "✗ $domain 网络连接失败"
        fi
    done
}

# 文件操作函数
upload_file() {
    read -p "请输入本地文件路径: " local_file
    read -p "请输入目标存储空间名: " bucket

    s3cmd put "$local_file" "s3://$bucket/"
}

download_file() {
    read -p "请输入存储空间名: " bucket
    read -p "请输入远程文件名: " remote_file
    read -p "请输入本地保存路径: " local_path

    s3cmd get "s3://$bucket/$remote_file" "$local_path"
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo "多云存储 S3cmd 管理脚本"
        echo "================="
        echo "1. 安装 s3cmd"
        echo "2. 配置 s3cmd"
        echo "3. 系统兼容性检查"
        echo "4. 网络连接测试"
        echo "5. 上传文件"
        echo "6. 下载文件"
        echo "7. 退出"

        read -p "请选择操作 (1-7): " choice

        case $choice in
            1) install_s3cmd ;;
            2) configure_s3cmd ;;
            3) system_check ;;
            4) test_network ;;
            5) upload_file ;;
            6) download_file ;;
            7) exit 0 ;;
            *)
                echo "无效选择"
                sleep 2
                ;;
        esac

        read -p "按回车键继续..." pause
    done
}

# 脚本入口
main_menu