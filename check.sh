################################################################### 
# Description: A Bench Script by Teddysun                         #
#                                                                 #
# Copyright (C) 2015 - 2022 Teddysun <i@teddysun.com>             #
# Thanks: LookBack <admin@dwhd.org>                               #
# URL: https://teddysun.com/444.html                              #
# https://github.com/teddysun/across/blob/master/bench.sh         #
################################################################### 
 
 
 
 trap _exit INT QUIT TERM

_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
}

_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
}

_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
}

_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
}

_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

_exit() {
    _red "\nThe script has been terminated.\n"
    # clean up
  
    exit 1
}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}






calc_size() {
    local raw=$1
    local total_size=0
    local num=1
    local unit="KB"
    if ! [[ ${raw} =~ ^[0-9]+$ ]] ; then
        echo ""
        return
    fi
    if [ "${raw}" -ge 1073741824 ]; then
        num=1073741824
        unit="TB"
    elif [ "${raw}" -ge 1048576 ]; then
        num=1048576
        unit="GB"
    elif [ "${raw}" -ge 1024 ]; then
        num=1024
        unit="MB"
    elif [ "${raw}" -eq 0 ]; then
        echo "${total_size}"
        return
    fi
    total_size=$( awk 'BEGIN{printf "%.1f", '$raw' / '$num'}' )
    echo "${total_size} ${unit}"
}

check_virt(){
    _exists "dmesg" && virtualx="$(dmesg 2>/dev/null)"
    if _exists "dmidecode"; then
        sys_manu="$(dmidecode -s system-manufacturer 2>/dev/null)"
        sys_product="$(dmidecode -s system-product-name 2>/dev/null)"
        sys_ver="$(dmidecode -s system-version 2>/dev/null)"
    else
        sys_manu=""
        sys_product=""
        sys_ver=""
    fi
    if   grep -qa docker /proc/1/cgroup; then
        virt="Docker"
    elif grep -qa lxc /proc/1/cgroup; then
        virt="LXC"
    elif grep -qa container=lxc /proc/1/environ; then
        virt="LXC"
    elif [[ -f /proc/user_beancounters ]]; then
        virt="OpenVZ"
    elif [[ "${virtualx}" == *kvm-clock* ]]; then
        virt="KVM"
    elif [[ "${sys_product}" == *KVM* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *KVM* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *QEMU* ]]; then
        virt="KVM"
    elif [[ "${virtualx}" == *"VMware Virtual Platform"* ]]; then
        virt="VMware"
    elif [[ "${sys_product}" == *"VMware Virtual Platform"* ]]; then
        virt="VMware"
    elif [[ "${virtualx}" == *"Parallels Software International"* ]]; then
        virt="Parallels"
    elif [[ "${virtualx}" == *VirtualBox* ]]; then
        virt="VirtualBox"
    elif [[ -e /proc/xen ]]; then
        if grep -q "control_d" "/proc/xen/capabilities" 2>/dev/null; then
            virt="Xen-Dom0"
        else
            virt="Xen-DomU"
        fi
    elif [ -f "/sys/hypervisor/type" ] && grep -q "xen" "/sys/hypervisor/type"; then
        virt="Xen"
    elif [[ "${sys_manu}" == *"Microsoft Corporation"* ]]; then
        if [[ "${sys_product}" == *"Virtual Machine"* ]]; then
            if [[ "${sys_ver}" == *"7.0"* || "${sys_ver}" == *"Hyper-V" ]]; then
                virt="Hyper-V"
            else
                virt="Microsoft Virtual Machine"
            fi
        fi
    else
        virt="Dedicated"
    fi
}

ipv4_info() {
    local org="$(wget -q -T10 -O- ipinfo.io/org)"
    local city="$(wget -q -T10 -O- ipinfo.io/city)"
    local country="$(wget -q -T10 -O- ipinfo.io/country)"
    local region="$(wget -q -T10 -O- ipinfo.io/region)"
    if [[ -n "$org" ]]; then
        echo " Organization       : $(_blue "$org")"
    fi
    if [[ -n "$city" && -n "country" ]]; then
        echo " Location           : $(_blue "$city / $country")"
    fi
    if [[ -n "$region" ]]; then
        echo " Region             : $(_yellow "$region")"
    fi
    if [[ -z "$org" ]]; then
        echo " Region             : $(_red "No ISP detected")"
    fi
}



print_intro() {
#依赖文件
ARCH_NFTools=$(uname -m)
# 判断 CPU 架构是否为 amd64
if [ "$ARCH_NFTools" = "x86_64" ]; then
  wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0/nf_linux_amd64 && chmod +x nf && clear

# 判断 CPU 架构是否为 arm64
elif [ "$ARCH_NFTools" = "aarch64" ]; then
  wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0/nf_linux_arm64 && chmod +x nf && clear


else
  echo "错误：不支持的 CPU 架构(Netflix检测无法运行)：$ARCH_NFTools"
fi


    echo "-------------------- MJJ_Vps_ToolBox -------------------"
}

# Get System information
get_system_info() {
    cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    cores=$( awk -F: '/processor/ {core++} END {print core}' /proc/cpuinfo )
    freq=$( awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo )
    ccache=$( awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    cpu_aes=$( grep -i 'aes' /proc/cpuinfo )
    cpu_virt=$( grep -Ei 'vmx|svm' /proc/cpuinfo )
    tram=$( LANG=C; free | awk '/Mem/ {print $2}' )
    tram=$( calc_size $tram )
    uram=$( LANG=C; free | awk '/Mem/ {print $3}' )
    uram=$( calc_size $uram )
    swap=$( LANG=C; free | awk '/Swap/ {print $2}' )
    swap=$( calc_size $swap )
    uswap=$( LANG=C; free | awk '/Swap/ {print $3}' )
    uswap=$( calc_size $uswap )
    up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
    if _exists "w"; then
        load=$( LANG=C; w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    elif _exists "uptime"; then
        load=$( LANG=C; uptime | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    fi
    opsy=$( get_opsy )
    arch=$( uname -m )
    if _exists "getconf"; then
        lbit=$( getconf LONG_BIT )
    else
        echo ${arch} | grep -q "64" && lbit="64" || lbit="32"
    fi
    kern=$( uname -r )
    disk_total_size=$( LANG=C; df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total 2>/dev/null | grep total | awk '{ print $2 }' )
    disk_total_size=$( calc_size $disk_total_size )
    disk_used_size=$( LANG=C; df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total 2>/dev/null | grep total | awk '{ print $3 }' )
    disk_used_size=$( calc_size $disk_used_size )
    tcpctrl=$( sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}' )
}
# Print System information
print_system_info() {
    if [ -n "$cname" ]; then
        echo " CPU Model          : $(_blue "$cname")"
    else
        echo " CPU Model          : $(_blue "CPU model not detected")"
    fi
    if [ -n "$freq" ]; then
        echo " CPU Cores          : $(_blue "$cores @ $freq MHz")"
    else
        echo " CPU Cores          : $(_blue "$cores")"
    fi
    if [ -n "$ccache" ]; then
        echo " CPU Cache          : $(_blue "$ccache")"
    fi
    if [ -n "$cpu_aes" ]; then
        echo " AES-NI             : $(_green "Enabled")"
    else
        echo " AES-NI             : $(_red "Disabled")"
    fi
    if [ -n "$cpu_virt" ]; then
        echo " VM-x/AMD-V         : $(_green "Enabled")"
    else
        echo " VM-x/AMD-V         : $(_red "Disabled")"
    fi
    echo " Total Disk         : $(_yellow "$disk_total_size") $(_blue "($disk_used_size Used)")"
    echo " Total Mem          : $(_yellow "$tram") $(_blue "($uram Used)")"
    if [ "$swap" != "0" ]; then
        echo " Total Swap         : $(_blue "$swap ($uswap Used)")"
    fi
    echo " System uptime      : $(_blue "$up")"
    echo " Load average       : $(_blue "$load")"
    echo " OS                 : $(_blue "$opsy")"
    echo " Arch               : $(_blue "$arch ($lbit Bit)")"
    echo " Kernel             : $(_blue "$kern")"
    echo " TCP CC             : $(_yellow "$tcpctrl")"
    echo " Virtualization     : $(_blue "$virt")"
}



print_OpenAI_check() {
 
 BLUE="\033[36m"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
 


   sleep 1

    
    SUPPORT_COUNTRY=(AL DZ AD AO AG AR AM AU AT AZ BS BD BB BE BZ BJ BT BO BA BW BR BN BG BF CV CA CL CO KM CG CR CI HR CY CZ DK DJ DM DO EC SV EE FJ FI FR GA GM GE DE GH GR GD GT GN GW GY HT VA HN HU IS IN ID IQ IE IL IT JM JP JO KZ KE KI KW KG LV LB LS LR LI LT LU MG MW MY MV ML MT MH MR MU MX FM MD MC MN ME MA MZ MM NA NR NP NL NZ NI NE NG MK NO OM PK PW PS PA PG PY PE PH PL PT QA RO RW KN LC VC WS SM ST SN RS SC SL SG SK SI SB ZA KR ES LK SR SE CH TW TZ TH TL TG TO TT TN TR TV UG UA AE GB US UY VU ZM)


if [[ $(curl -sS https://chat.openai.com/ -I | grep "text/plain") != "" ]]
then
	echo "你的IP似乎被openai封禁了"
else
	echo -e "[IPv4]"
	check4=`ping 1.1.1.1 -c 1 2>&1`;
	if [[ "$check4" != *"received"* ]] && [[ "$check4" != *"transmitted"* ]];then
		echo -e "\033[34m你的IP似乎不能解锁OpenAI \033[0m";
	else
		# local_ipv4=$(curl -4 -s --max-time 10 api64.ipify.org)
		local_ipv4=$(curl -4 -sS https://chat.openai.com/cdn-cgi/trace | grep "ip=" | awk -F= '{print $2}')
		local_isp4=$(curl -s -4 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv4}" | grep organization | cut -f4 -d '"')
		#local_asn4=$(curl -s -4 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv4}" | grep asn | cut -f8 -d ',' | cut -f2 -d ':')
		echo -e "${BLUE}Your IPv4: ${local_ipv4} - ${local_isp4}${PLAIN}"
		iso2_code4=$(curl -4 -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
		if [[ "${SUPPORT_COUNTRY[@]}"  =~ "${iso2_code4}" ]]; 
		then
			echo -e "${GREEN}你的IP似乎可以解锁OpenAI 地区: ${iso2_code4}${PLAIN}" 
		else
			echo -e "${RED}Region: ${iso2_code4}. 你的IP似乎不支持OPENAI. ${PLAIN}"
		fi
	fi
	echo "-------------------------------------"
	echo -e "[IPv6]"
	check6=`ping6 240c::6666 -c 1 2>&1`;
	if [[ "$check6" != *"received"* ]] && [[ "$check6" != *"transmitted"* ]];then
		echo -e "\033[34m你的主机似乎不支持IPV6\033[0m";    
	else
		# local_ipv6=$(curl -6 -s --max-time 20 api64.ipify.org)
		local_ipv6=$(curl -6 -sS https://chat.openai.com/cdn-cgi/trace | grep "ip=" | awk -F= '{print $2}')
		local_isp6=$(curl -s -6 --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv6}" | grep organization | cut -f4 -d '"')
		#local_asn6=$(curl -s -6 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv6}" | grep asn | cut -f8 -d ',' | cut -f2 -d ':')
		echo -e "${BLUE}Your IPv6: ${local_ipv6} - ${local_isp6}${PLAIN}"
		iso2_code6=$(curl -6 -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
		if [[ "${SUPPORT_COUNTRY[@]}"  =~ "${iso2_code6}" ]]; 
		then
			echo -e "${GREEN}你的IP似乎可以解锁OPENAI 地区: ${iso2_code6}${PLAIN}" 
		else
			echo -e "${RED}Region: ${iso2_code6}. 你的IP似乎不支持OPENAI    .${PLAIN}"
		fi
	fi

fi

}

print_Netflix_check() {

./nf
#清除残留文件
rm -f nf



}
    


! _exists "wget" && _red "Error: wget command not found.\n" && exit 1
! _exists "free" && _red "Error: free command not found.\n" && exit 1
start_time=$(date +%s)

get_system_info

check_virt
clear

#文件头
print_intro

#系统信息
print_system_info
#IP信息
ipv4_info
#分割线
next
#OpenAI检测
print_OpenAI_check
#分割线
next
#奈飞检测
print_Netflix_check
#分割线
next
 
 curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
 
 next

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
