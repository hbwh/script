#! /bin/sh
apt-get update
apt-get -y upgrade
apt-get -y install pptpd iptables
echo "localip 10.121.116.1" >> /etc/pptpd.conf
echo "remoteip 10.121.116.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options
echo "ms-dns 8.8.4.4" >> /etc/ppp/options
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "Pleast enther pptp user name"
read username
echo "Pleast enther pptp password"
read password
echo "$username pptpd $password *" >> /etc/ppp/chap-secrets
service pptpd restart
echo "Pleast enther IP address"
read ipad
cat > /etc/pptpdfirewall.sh << EOF
iptables -t nat -A POSTROUTING -s 10.121.116.0/24 -j SNAT --to-source $ipad
iptables -A FORWARD -s 10.121.116.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
EOF
chmod 755 /etc/pptpdfirewall.sh
echo "sh /etc/pptpdfirewall.sh" >> /etc/init.d/rc.local
