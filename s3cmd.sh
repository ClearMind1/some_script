#!/bin/bash

# 检查是否已安装 s3cmd
check_s3cmd_installed() {
    if ! command -v s3cmd &> /dev/null
    then
        echo "s3cmd 未安装，正在安装..."
        sudo apt update
        sudo apt-get install -y s3cmd
    else
        echo "s3cmd 已安装"
    fi
}

# 配置 s3cmd 适配千牛云
configure_qiniu_s3cmd() {
    echo "开始配置千牛云 s3cmd..."

    # 交互式输入配置信息
    read -p "请输入千牛云 Access Key: " access_key
    read -sp "请输入千牛云 Secret Key: " secret_key
    echo

    read -p "请输入存储区域 (例如 cn-east-1): " region
    read -p "请输入存储空间名称: " bucket

    # 千牛云 S3 兼容节点
    qiniu_endpoint="s3-${region}.qiniu.com"

    # 创建配置文件
    mkdir -p ~/.s3cfg
    cat > ~/.s3cfg << EOF
[default]
access_key = ${access_key}
secret_key = ${secret_key}
host_base = ${qiniu_endpoint}
host_bucket = %(bucket)s.${qiniu_endpoint}
use_https = True
signature_v2 = False
EOF

    echo "千牛云 s3cmd 配置完成"
}

# 测试 S3 连接
test_s3_connection() {
    echo "正在测试千牛云 S3 连接..."
    s3cmd ls
    if [ $? -eq 0 ]; then
        echo "S3 连接成功"
    else
        echo "S3 连接失败，请检查配置"
    fi
}

# 添加常用操作函数
upload_file() {
    read -p "请输入要上传的本地文件路径: " local_file
    read -p "请输入目标存储空间: " bucket

    s3cmd put "${local_file}" "s3://${bucket}/"
}

download_file() {
    read -p "请输入要下载的文件名: " remote_file
    read -p "请输入存储空间名称: " bucket
    read -p "请输入本地保存路径: " local_path

    s3cmd get "s3://${bucket}/${remote_file}" "${local_path}"
}

# 主菜单
main_menu() {
    while true; do
        echo "千牛云 S3cmd 配置脚本"
        echo "1. 安装/检查 s3cmd"
        echo "2. 配置千牛云 s3cmd"
        echo "3. 测试 S3 连接"
        echo "4. 上传文件"
        echo "5. 下载文件"
        echo "6. 列出存储空间文件"
        echo "7. 退出"

        read -p "请选择操作 (1-7): " choice

        case $choice in
            1) check_s3cmd_installed ;;
            2) configure_qiniu_s3cmd ;;
            3) test_s3_connection ;;
            4) upload_file ;;
            5) download_file ;;
            6)
                read -p "请输入存储空间名称: " bucket
                s3cmd ls "s3://${bucket}/"
                ;;
            7) exit 0 ;;
            *) echo "无效的选择，请重新输入" ;;
        esac

        echo
    done
}

# 脚本入口点
main_menu