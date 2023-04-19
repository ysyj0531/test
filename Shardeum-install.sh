#!/bin/bash

# 提示信息
echo "shardeum节点自动化部署脚本，此脚本安装系统为CentOS 7.6，建议硬件设备为4核CPU-4GB内存-40GB存储空间。提示：该脚本安装时间较长（初次安装预计时间为10-15分钟，占用5-7GB空间），现在开始20秒钟等待确认时间，如果选择不安装请运行Ctrl+C键退出"
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
sudo yum update -y

# 安装yum-utils，docker依赖程序
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 添加Docker源并安装docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# 安装最新版本docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 检查docker版本
docker -v
docker-compose -v

# 开始节点程序安装
echo -e "y\ny\n778899\n1988\n\n\n\n" | curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && echo -e "y\n778899\n1988\n\n\n" | ./installer.sh -s

# 防火墙设置
sudo firewall-cmd --zone=docker --add-service=ssh
sudo firewall-cmd --zone=docker --add-port=1988/tcp
sudo firewall-cmd --zone=docker --add-service=https
sudo firewall-cmd --zone=docker --add-service=http
sudo firewall-cmd --zone=docker --add-port=443/tcp
sudo firewall-cmd --reload
sudo systemctl enable firewalld
sudo systemctl start firewalld

# 转到隐藏的Shardeum目录
cd ~/.shardeum

# 通过运行shell脚本启动CLI
./shell.sh

# 显示启动界面
operator-cli gui start

# 检查pm2列表
pm2 list

# 获取本地IP地址
EXTERNAL_IP=$(curl -s ifconfig.me)

# 输出仪表盘链接信息
echo "安装完毕！！！"
echo "如果提示安装成功还无法打开网页，请检查服务器安全组是否禁止了1988、9001、10001端口，如果有，请关闭安全组并打开端口。"
echo "请通过 https://$EXTERNAL_IP:1988 或 http://$EXTERNAL_IP:1988打开仪表盘网页"
echo "shardeum节点仪表盘密码：778899"

