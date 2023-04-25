# 检查是否为root用户
if [ "$EUID" -ne 0 ]
  then echo "请使用root用户运行脚本！"
  exit
fi

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

sudo apt-get install curl
# 更新服务器
sudo apt update && apt upgrade -y

# 安装软件包
sudo apt-get install ca-certificates curl gnupg lsb-release

# 安装expect命令
sudo apt-get install expect

# 添加 Docker 软件源
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装 Docker 和 Docker Compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt install docker-compose

# 检查 Docker 版本添加权限
docker -v
docker-compose -v
sudo chmod +x /usr/bin/docker-compose

# 启动 Docker
systemctl start docker

# 开始节点程序安装
curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh


# 防火墙设置
ufw allow ssh
ufw allow 8080
ufw allow https
ufw allow http
ufw allow 443
ufw enable


# 转到隐藏的 Shardeum 目录
cd
cd ~/.shardeum

# 通过运行 shell 脚本启动 CLI
nohup ./shell.sh & "operator-cli gui start"

# 获取本地 IP 地址
EXTERNAL_IP=$(curl -s ifconfig.me)

# 输出仪表盘链接信息
echo "安装完毕！！！"
echo "如果提示安装成功还无法打开网页，请检查服务器安全组是否禁止了相关端口，如果有，请关闭安全组并打开端口。"
echo "请通过 https://$EXTERNAL_IP:+设置的端口 （默认为8080）打开仪表盘网页"
echo "shardeum节点仪表盘密码：你设置的密码"
echo "shardeum节更新请重新运行本脚本，注意解除质押"

