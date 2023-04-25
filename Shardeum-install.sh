#!/bin/bash

# 提示信息
echo "shardeum节点自动化部署脚本，此脚本安装系统为Ubuntu，建议硬件设备为4核CPU-4GB内存-40GB存储空间。提示：该脚本安装时间较长（初次安装预计时间为10-15分钟，占用5-7GB空间），现在开始20秒钟等待确认时间，如果选择不安装请运行Ctrl+C键退出"
echo ""

# 20秒等待用户确认，如果用户在此期间输入Ctrl+C，则退出脚本
for (( i=20; i>0; i-- )); do
    echo -ne "等待用户确认时间：$i\033[0K\r"
    read -t 1 -n 3 key
    if [[ $key = $'\033w' ]]; then
        echo -e "\n已选择退出脚本！"
        exit
    fi
done

# 更新服务器
sudo apt update -y
sudo apt upgrade -y

# 安装软件包
sudo apt install -y git apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# 添加 Docker GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 添加 Docker 软件源
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装 Docker 和 Docker Compose
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 检查 Docker 版本
docker -v
docker-compose -v

# 启动 Docker
sudo systemctl start docker

# 开始节点程序安装
curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh

# 防火墙设置
sudo ufw allow ssh
sudo ufw allow 8080/tcp
sudo ufw allow https
sudo ufw allow http
sudo ufw allow 443/tcp
sudo ufw enable

# 转到隐藏的 Shardeum 目录
cd ~/.shardeum

# 通过运行 shell 脚本启动 CLI
./shell.sh

# 显示启动界面
operator-cli gui start

# 检查 pm2 列表
pm2 list

# 获取本地 IP 地址
EXTERNAL_IP=$(curl -s ifconfig.me)

# 输出仪表盘链接信息
echo "安装完毕！！！"
echo "如果提示安装成功还无法打开网页，请检查服务器安全组是否禁止了相关端口，如果有，请关闭安全组并打开端口。"
echo "请通过 https://$EXTERNAL_IP:+设置的端口 或 http://$EXTERNAL_IP:设置的端口  打开仪表盘网页"
echo "shardeum节点仪表盘密码：你设置的密码"

