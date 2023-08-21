#!/bin/sh
#Autor: Henry Chumo 
#Alias : ChumoGH
## 1 - "LIMPEZA DE DNS"
ip -s -s neigh flush all &> /dev/null
ip neigh flush dev $(ip route | grep default | awk '{print $5}' | head -1) &> /dev/null
## 2 - "CACHE DO SISTEMA"
echo 3 > /proc/sys/vm/drop_caches &> /dev/null
## 2 - "LIMPAR LOGS"
echo > /var/log/messages
echo > /var/log/kern.log
echo > /var/log/daemon.log
echo > /var/log/kern.log
echo > /var/log/dpkg.log
echo > /var/log/syslog
#echo > /var/log/auth.log
swapoff -a && swapon -a &> /dev/null
killall kswapd0 &> /dev/null
[[ $1 = '--free' ]] && echo $(free -h | grep Mem | sed 's/\s\+/,/g' | cut -d , -f4) > /bin/ejecutar/raml
