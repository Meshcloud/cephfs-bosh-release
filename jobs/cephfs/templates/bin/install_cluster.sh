#!/bin/bash

set -x

PWD=`pwd`
user=vcap
hostname=`hostname`
ipaddr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
ifcace=$(ifconfig | grep encap:Ethernet | cut -d" " -f1)
firstadress=<%= p(link("storage").instances.first.address) %>

#Setup of Ceph Admin Node 

#TODO: Add check for this Node being the admin Node

if["$ipaddr" == "$firstadress"]; then 	
	echo "Being on Admin Host $ipaddr installing Ceph Admin tools"
	wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
	echo deb https://download.ceph.com/debian/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
	sudo apt update
	sudo apt install ceph-deploy
else 
	echo "not the admin host $ipaddr" 
fi		

#Preflight Setup of all Nodes including Admin one
##Installing SSH and establishing the Keys
echo "configuring ssh server..."
username=<%= p("cephfs.username") %>
sshpubkey=<%= p("cephfs.sshpubkey") %>
sudo apt install ntp
sudo apt install openssh-server
sudo useradd -d /home/$username -m $username
sudo passwd $username
echo "$username ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
sudo chmod 0440 /etc/sudoers.d/$username
echo $sshpubkey > /home/$username/.ssh/authorized_keys 

if["$ipaddr" == "$firstadress"]; then
	echo "Adding SSH-Config..."
	sshprivkey=<%= p("cephfs.sshprivkey") %>
	echo sshprivkey > priv.rsa

	clusternodes=<%= p(link("storage").instances) %>

	for(i in "${clusternodes[@]}")
	do
	 echo "Host $i.address" >> ~/.ssh/config	
	 echo "	Hostname $i.address" >> ~/.ssh/config	
	 echo "	User $username" >> ~/.ssh/config
	 echo "	IdentityFile ~/.ssh/config/priv.rsa" >> ~/.ssh/config

	done	

#add etc Hosts fot 
cat<<EOF >>hosts
127.0.0.1       localhost
$ipaddr         $hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
sudo mv hosts /etc/hosts
else
	echo "being no admin host skipping SSH Confg"
fi		

#open ports and save config
echo "Adding Routes..."
sudo apt-get install iptables-persistent
sudo iptables -A INPUT -i $iface -p tcp -s $ipaddr/255.255.255.0 --dport 6789 -j ACCEPT
sudo iptables -A INPUT -i $iface -p tcp -s $ipaddr/255.255.255.0 --dport 6800:7300 -j ACCEPT
sudo /etc/init.d/iptables-persistent save 







