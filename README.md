# VPS_ToolBox




wget -N --no-check-certificate "https://raw.githubusercontent.com/Mrmineduce21/VPS_ToolBox/main/toolbox.sh" && chmod +X toolbox.sh && bash toolbox.sh

======================================================================

# 流媒体脚本
原版是在落地机（能解锁的）安装dnsmasq+sniproxy，把本机（需要解锁的机器）DNS改为落地鸡的ip，就可以实现解锁。  
但是有个问题，一旦落地鸡挂了，就可能导致本机DNS错误直接无法上网，而且本机所有域名都要经过落地鸡DNS解析，这就很不舒服。

本脚本原理：  
在落地鸡只安装sniproxy，在本机安装dnsmasq，并把系统DNS改为127.0.0.1，通过dnsmasq的DNS配置分流，不必所有域名都经过落地鸡解析

# 一、能解锁的落地机：安装sniproxy
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/myxuchangbin/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -fs

-is, --安装 SNI Proxy  
-fs, --快速安装 SNI Proxy  
-us, --卸载 SNI Proxy

### 如果用ipv6解锁
修改配置/etc/sniproxy.conf 重启机器  
resolver {  
     mode ipv6_first  
 }
 
ipv4_only：query for IPv4 addresses (default)  
ipv6_only：query for IPv6 addresses  
ipv4_first：query for both IPv4 and IPv6, use IPv4 is present  
ipv6_first：query for both IPv4 and IPv6, use IPv6 is present  

### 代理域名列表（白名单）
默认已包含Netflix Hulu HBO等大部分常见流媒体域名，具体文件/etc/sniproxy.conf，此列表只增不减  
如果只想解锁其中部分网站，在下面的dnsmasq分流文件改就可以。

# 二、不能解锁的机器：安装dnsmasq
wget --no-check-certificate -O unlock.sh https://raw.githubusercontent.com/Mrmineduce21/VPS_ToolBox/main/unlock.sh && chmod +x unlock.sh  
./unlock.sh ip

ping netflix.com  显示的是你的解锁机ip  
cat /etc/resolv.conf  查看本机DNS是127.0.0.1  
那说明解锁成功

### dnsmasq的分流配置文件
/etc/dnsmasq.d/unlock.conf  

系统DNS修改为127.0.0.1后，unlock.conf的DNS配置已经取代了系统DNS，建议把下面的配置改为系统原本的DNS（查看备份文件/etc/resolv.conf.bak）  
server=8.8.8.8  
server=1.1.1.1  
server=208.67.222.222  

默认包含的流媒体域名和上面sniproxy的配置文件一样  
增加解锁域名：unlock.conf和sniproxy.conf 都要增加  
减少解锁域名：例如本机除了Netflix不解，其他全部流媒体本身都能解。那unlock.conf只保留Netflix系列域名就行，不要改sniproxy.conf

### 取消解锁：
./unlock.sh r

### 手动取消解锁：
chattr -i /etc/resolv.conf  
cat > /etc/resolv.conf <<EOF  
nameserver 8.8.8.8  
nameserver 1.1.1.1  
EOF  
systemctl stop dnsmasq  
systemctl disable dnsmasq

### 服务类命令
systemctl enable dnsmasq && systemctl start dnsmasq  
systemctl stop dnsmasq && systemctl disable dnsmasq  
systemctl restart dnsmasq && systemctl status dnsmasq 
 
systemctl enable sniproxy &&systemctl start sniproxy  
systemctl stop sniproxy && systemctl disable sniproxy              
systemctl restart sniproxy && systemctl status sniproxy

### 系统DNS相关命令
加锁DNS文件  
chattr +i /etc/resolv.conf  
解锁DNS文件  
chattr -i /etc/resolv.conf  
查看本机DNS  
cat /etc/resolv.conf

### iptables相关命令（解锁机上执行，防止被盗用代理）
入站：先禁止所有ip访问80/443端口（执行一次就行）  
iptables -I INPUT -p tcp --dport 443 -j DROP  
iptables -I INPUT -p tcp --dport 80 -j DROP

入站：放行某个ip访问80/443端口（按需添加）  
iptables -I INPUT -s ip -p tcp --dport 443 -j ACCEPT  
iptables -I INPUT -s ip -p tcp --dport 80 -j ACCEPT  
service iptables save

iptables配置文件/etc/sysconfig/iptables，修改重启服务生效service iptables restart   

资料  
https://github.com/myxuchangbin/dnsmasq_sniproxy_install  
https://raw.githubusercontent.com/myxuchangbin/dnsmasq_sniproxy_install/master/sniproxy.conf

