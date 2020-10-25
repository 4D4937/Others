# -*- coding: utf-8 -*-
import os

os.system("apt-get install expect -y")
node_name = raw_input("Enter node name")
user_name = raw_input('Enter user name')
ip_address = raw_input('Enter ip address')
password = raw_input('Enter password')

f = open('/home/zrhe2016/' + str(node_name) + '.sh','w')
f.write('#!/usr/bin/expect\n' + 'spawn ssh ' + str(user_name) + '@' + str(ip_address) + '\n' + 'expect "*password:"\n' + 'send "' + str(password) + '\\' + 'r"\n' + 'interact\n')
f.close()

os.system('chmod 777 ' + node_name + '.sh')
with open("/root/.bashrc" ,mode="a") as data:
    data.write('alias ' + node_name + '=' + '\'/home/zrhe2016/' + str(node_name) + '.sh\'' + '\n')
os.system('/bin/bash -c "source /root/.bashrc"')
