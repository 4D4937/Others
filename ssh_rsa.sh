#!/usr/bin/env bash
clear

config_file='/etc/ssh/sshd_config'

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#check OS version
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

#ssh_config
mkdir .ssh
cd /root/.ssh/ || exit
touch authorized_keys
wget https://raw.githubusercontent.com/4D4937/Others/master/libertyss_rsa.pub
cat /root/.ssh/libertyss_rsa.pub >>  /root/.ssh/authorized_keys
sed -i "s/#RSAAuthentication/RSAAuthentication/g" ${config_file}
sed -i "s/#PubkeyAuthentication/PubkeyAuthentication/g" ${config_file}
sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" ${config_file} 
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" ${config_file}

service sshd restart
systemctl restart sshd


echo done!
