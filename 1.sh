#!/bin/bash
#Filename: interactive.sh
read -p "请输入要做bond的网卡第一块网卡名称:" em1
read -p "请输入要做bond的网卡第二块网卡名称:" em2
read -p "请输入bond后的ip:" bond_ip
read -p "请输入bond后的掩码:" bond_netmask
read -p "请输入bond后的网关:" bond_gate
ifc="/etc/sysconfig/network-scripts/ifcfg-"

cat > /etc/sysconfig/network-scripts/ifcfg-bond0 <<EOF
TYPE=Bond
DEVICE=bond0
BOOTPROTO=static
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=no
BONDING_MASTER=yes
BONDING_OPTS="fail_over_mac=1 miimon=200 mode=1"
NAME=bond0
IPADDR=$bond_ip
PREFIX=$bond_netmask
GATEWAY=$bond_gate
DNS1=8.8.8.8
EOF

cat > $ifc$em1 <<EOF
DEVICE=$em1
TYPE=Ethernet
BOOTPROTO=none
USERCTL=no
ONBOOT=yes
NAME=$em1
MASTER=bond0
SLAVE=yes
EOF
cat > $ifc$em2 <<EOF
DEVICE=$em2
TYPE=Ethernet
BOOTPROTO=none
USERCTL=no
ONBOOT=yes
NAME=$em2
MASTER=bond0
SLAVE=yes
EOF

cat > /etc/modprobe.d/bond.conf <<EOF
alias bond0 bonding
options bond0 miimon=200 mode=1
EOF

cat > /etc/sysconfig/modules/bonding.modules <<EOF
#!/usr/bin/bash
/usr/sbin/modinfo -F filename bonding > /dev/null 2>&1
if [ $? -eq 0 ];then
/usr/sbin/modprobe bonding
fi
EOF
chmod 755 /etc/sysconfig/modules/bonding.modules

systemctl stop NetworkManager

systemctl disable NetworkManager
