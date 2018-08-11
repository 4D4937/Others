#!/bin/bash
# ex: ./authorized.sh username 
username=$1
flag=""

function f_user_permission
{
    useradd $username
    mkdir /home/$username/.ssh
    touch /home/$username/.ssh/authorized_keys
    read -p "please input your public key:" public_key
    echo $public_key >> /home/$username/.ssh/authorized_keys
    chmod 600 /home/$username/.ssh/authorized_keys
    cd /home
    chown -R $username:$username ./$username
    sed -i "s/AllowUsers.*/& $username/g" /etc/ssh/sshd_config
    /etc/init.d/sshd reload
}

function f_user_add
{
    if [ "$1" == 2 ]
    then
        echo "f_user_permission 2"
        f_user_permission
        flag="0"        
    elif [ "$1" == 1 ]
    then
        echo "f_user_permission 1"
        echo "back up the original user dir: ${username} to ${username}_bak"
        mv $username ${username}_bak
        f_user_permission
        flag="0"
    else
        echo "f_user_add parm error"
        flag="1"
    fi
}



if [ -z "$username" ]
then
    echo -e "\033[31m please execute the shell like this:\n\" ./authorized.sh liyg\" to add the user \"liyg\"\033[0m"
    echo "no user name input,nothing to do,exit"
else
    echo "check user"
    user_check=`cat /etc/passwd |grep "$username"`
    if [ -z "$user_check" ]
    then
        echo "start"
        user_dir_check="/home/$username"
        if [ -d "$user_dir_check" ]
        then
            echo "1"
            f_user_add 1
        else
            echo "2"
            f_user_add 2
        fi
    else
        echo "user $username exists ,please check out, stopping add user"
        flag="1"
    fi
fi


if [ "$flag" == "0" ]
then
    echo "${username}'s permission already opened"
elif [ "$flag" == "1" ]
then
    echo "${username}'s permission denied"
else
    echo "parameter error"
fi
