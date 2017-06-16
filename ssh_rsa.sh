#!/usr/bin/env bash
clear

config_file='/etc/ssh/sshd_config'

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#ssh_config
cd /root/.ssh/ || exit
wget https://github.com/4D4937/Others/edit/master/libertyss_rsa.pub
cat /root/.ssh/libertyss_rsa.pub >>  /root/.ssh/authorized_keys
sed -i "47s/#/ /g" ${config_file}
sed -i "48s/#/ /g" ${config_file}
sed -i "49s/#/ /g" ${config_file} 
sed -i "64s/yes/no/g" ${config_file}

service sshd restart

echo done!
