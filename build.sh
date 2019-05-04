apt-get install subversion build-essential libssl-dev autoconf -y

wget https://github.com/4D4937/Others/raw/master/N1
wget https://github.com/4D4937/Others/raw/master/N2
clear

echo #############################
echo #                           #
echo #LIBER+ Pnetwork Bulid Shell#
echo #                           #
echo #############################

read -p "网络名称:" network_name
read -p "中心节点ip:" cnode_ip
read -p "端口:" port
read -p "内网分配ip:" enode_ip
read -p "密钥:" network_pass

./N2 -a ${enode_address} -c ${network_name} -k ${network_pass} -l ${cnode_address}:${port}
./N1 -l ${port} -f -v
