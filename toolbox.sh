#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误：${plain} 必须使用root用户运行此脚本！\n" && exit 1
# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}未检测到系统版本，请联系脚本作者！${plain}\n" && exit 1
fi

#Install base
  echo -e "${yellow}install_base${plain} "
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release -y
        yum install wget socat bc curl sudo -y
    else
    apt-get install wget socat bc curl sudo -y
    fi

clear

   echo -e "${green}=====================================================================${plain} "
   echo -e "${green}@            VPS常用脚本集合          TG@oracle_abc                 @${plain} "
   echo -e "${green}@                                                                   @${plain} "
   echo -e "${green}@   1.BBr一键脚本                     2.流媒体检测脚本               @${plain} "
   echo -e "${green}@   3.服务器测试脚本                  4.安装宝塔7.7原版              @${plain} "
   echo -e "${green}@   5.宝塔7.7破解脚本                 6.XUI一键安装脚本              @${plain} "
   echo -e "${green}@   7.甲骨文DD_Debian11               8.甲骨文DD_WIN7                @${plain} "
   echo -e "${green}@   9.一键安装DDNS_GO                 10.XRAY一键搭建节点            @${plain} "
   echo -e "${green}=====================================================================${plain} "
   
   
   echo -e "${yellow}  均搜集自互联网，侵权请联系删除 ${plain} "


echo "请输入数字1-10："
read input

case $input in
  1)
    echo "你选择的是BBR一键脚本"
    wget -N --no-check-certificate "https://gist.github.com/zeruns/a0ec603f20d1b86de6a774a8ba27588f/raw/4f9957ae23f5efb2bb7c57a198ae2cffebfb1c56/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
    ;;
  2)
    echo "你选择的是流媒体检测"
    bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
    ;;
  3)
    echo "你选择的是秋水逸冰大佬的写的Bench.sh脚本"
    wget -qO- bench.sh | bash
    ;;
  4)
    echo "你选择的是安装宝塔7.7原版"
    curl -sSO https://raw.githubusercontent.com/zhucaidan/btpanel-v7.7.0/main/install/install_panel.sh && bash install_panel.sh
    ;;
  5)
    echo "你选择的是宝塔7.7破解脚本"
    curl -sSO https://cdn.cheshirex.com/uploads/sh/one_key_happy.sh && bash one_key_happy.sh
    ;;
  6)
    echo "你选择的是XUI一键安装脚本"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
    ;;
  7)
    echo "甲骨文DD_Debian11_默认密码【MoeClub.org】"
        echo "30秒后开始执行"
    sleep 30
    bash <(wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh') -d 11 -v 64 -a -firmware
    ;;
  8)
    echo "甲骨文DD_Windows_7_SP1【默认用户名：Administrator 密码：www.nat.ee】"
    echo "30秒后开始执行"
    sleep 30
    wget --no-check-certificate -qO InstallNET.sh 'http://d.nat.ee/sh/InstallNET.sh' && bash InstallNET.sh -dd 'http://d.nat.ee/oracle/Uefi-gpt-Win7-Ent.gz'
    ;;
  9)
    echo "一键安装DDNS_GO"
    wget -qO- https://raw.githubusercontent.com/JasonHe/ddns/main/ddns.sh | bash
    ;;
  10)
    echo "Xray一键安装【一键搭建节点】"
    bash <(curl -Ls https://raw.githubusercontent.com/atrandys/xray/main/install_triple_config.sh)
    ;;
  *)
    echo "输入无效数字！"
    ;;
esac

exit 0
