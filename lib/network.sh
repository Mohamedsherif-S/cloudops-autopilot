#! /bin/bash
get_network_interface(){
    ip -br addr | awk '$1 != "lo" && $2 == "UP" {print $1;exit}'
}
get_default_gateway(){
 ip route | awk '$1 == "default" {print $3;exit}'
}
check_gateway(){
    local gateway=$1
    if ping -c 1 -w 2 $gateway &>/dev/null;then 
        echo  -e "\033[32mNORMAL\033[0m: Gateway $gateway is reachable."
    else
        echo -e "\033[31mCRITICAL\033[0m: Gateway $gateway is unreachable."
    fi
}

check_internet(){
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo -e "\033[32mNORMAL\033[0m: Internet is reachable."
    else
        echo -e "\033[31mCRITICAL\033[0m: Internet is unreachable."
    fi
}
check_dns(){
    if getent hosts google.com &>/dev/null; then
        echo -e "\033[32mNORMAL\033[0m: DNS resolution is working."
    else
        echo -e "\033[31mCRITICAL\033[0m: DNS resolution failed."
    fi
}