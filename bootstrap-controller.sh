#!/usr/bin/env bash
sudo su
apt-get update
apt-get install -qy --no-install-recommends wget python git openssh-server openssh-client python-pip python-dev libxml2-dev libxslt-dev libssl-dev libffi-dev sudo vim telnet
apt-get clean
pip install flask pyeapi jsonrpc jsonrpclib exabgp
su - vagrant -c "git clone https://github.com/perimore/SR_Demo_Repo.git"
echo 'up route add -net 1.1.1.1 netmask 255.255.255.255 gw 10.10.10.1 dev eth1'
echo 'up route add -net 1.1.1.1 netmask 255.255.255.255 gw 10.10.10.1 dev eth1' >> /etc/network/interfaces
echo 'up route add -net 6.6.6.6 netmask 255.255.255.255 gw 10.10.10.2 dev eth1'
echo 'up route add -net 6.6.6.6 netmask 255.255.255.255 gw 10.10.10.2 dev eth1' >> /etc/network/interfaces
ifdown eth1
ifup eth1