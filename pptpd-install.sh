#! /bin/sh
apt-get update
apt-get -y upgrade
apt-get -y install pptpd iptables
apt-get -y autoremove
apt-get clean
echo "localip 10.121.116.1" >> /etc/pptpd.conf
echo "remoteip 10.121.116.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options
echo "ms-dns 8.8.4.4" >> /etc/ppp/options
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
read -p "Pleast enther pptp user name:" username
read -p "Pleast enther pptp password:" password
echo "$username pptpd $password *" >> /etc/ppp/chap-secrets
service pptpd restart
echo "Getting Public IP address, Please wait a moment..."

# Get Public IP address
<<<<<<< HEAD
IP=$(wget -O - http://ipv4.icanhazip.com/ -o /dev/null)
=======
IP=$(wget -O - http://icanhazip.com/ -o /dev/null)
>>>>>>> origin/master
if [[ "$IP" = "" ]]; then
    IP=$(wget -O - http://ipinfo.io -o /dev/null | grep "ip" | awk -F\" '{print $4}')
fi
echo -e "Your main public IP is\t\033[32m$IP\033[0m"

read -p "(Default IP: $IP):" ipad
if [ "$ipad" = "" ]; then
    ipad=IP
fi
cat > /etc/pptpdfirewall.sh << EOF
iptables -t nat -A POSTROUTING -s 10.121.116.0/24 -j SNAT --to-source $ipad
iptables -A FORWARD -s 10.121.116.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
EOF
chmod 755 /etc/pptpdfirewall.sh
echo "sh /etc/pptpdfirewall.sh" >> /etc/init.d/rc.local
