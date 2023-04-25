#!/usr/bin/expect -f

# 检查是否为root用户
if {[geteuid] != 0} {
    puts "请使用root用户运行脚本！"
    exit
}

# 提示信息
puts "shardeum节点自动化部署脚本，此脚本安装系统为Ubuntu，建议硬件设备为4核CPU-4GB内存-40GB存储空间。提示：该脚本安装时间较长（初次安装预计时间为10-15分钟，占用5-7GB空间），现在开始20秒钟等待确认时间，如果选择不安装请运行Ctrl+C键退出\n"

# 20秒等待用户确认，如果用户在此期间输入Ctrl+C，则退出脚本
for {set i 20} {$i > 0} {incr i -1} {
    puts -nonewline "等待用户确认时间：$i\r"
    sleep 1
    if {[catch {set key [read stdin 3]}] == 0} {
        if {$key eq "\x1bw"} {
            puts "\n已选择退出脚本！"
            exit
        }
    }
}

# 安装expect命令
apt-get update
apt-get -y install expect

# 添加 Docker 软件源
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装 Docker 和 Docker Compose
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose

# 检查 Docker 版本添加权限
docker -v
docker-compose -v
chmod +x /usr/local/bin/docker-compose

# 启动 Docker
systemctl start docker

# 开始节点程序安装
spawn curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh
expect {
    "continue" {
        send "\r"
        exp_continue
    }
    "Destination" {
        send "\r"
        exp_continue
    }
    "Enter your node name" {
        send "778899\r"
        exp_continue
    }
    "Enter your node description" {
        send "1988\r"
        exp_continue
    }
    "please enter your email" {
        send "\r"
        exp_continue
    }
    "press enter to generate new private key or enter the existing private key" {
        send "\r"
        exp_continue
    }
    "enter your private key" {
        send "\r"
        exp_continue
    }
    "are you sure you want to start the node" {
        send "\r"
        exp_continue
    }
}

# 防火墙设置
systemctl enable ufw
ufw allow ssh
ufw allow 8080/tcp
ufw allow https
ufw allow http
ufw allow 443
ufw --force enable


# 转到隐藏的 Shardeum 目录
cd
cd ~/.shardeum

# 通过运行 shell 脚本启动 CLI
./shell.sh "operator-cli gui start" "exit"

# 获取本地 IP 地址
EXTERNAL_IP=$(curl -s ifconfig.me)

# 输出仪表盘链接信息
echo "安装完毕！！！"
echo "如果提示安装成功还无法打开网页，请检查服务器安全组是否禁止了相关端口，如果有，请关闭安全组并打开端口。"
echo "请通过 https://$EXTERNAL_IP:+设置的端口 （默认为8080）打开仪表盘网页"
echo "shardeum节点仪表盘密码：你设置的密码"
echo "shardeum节更新请运行："

