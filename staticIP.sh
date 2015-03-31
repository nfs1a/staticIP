#!/bin/bash

getinfo()
{
  read -p "Enter static IP (looks like 192.168.0.105) : " staticip  
  read -p "Enter DefGw     (looks like 192.168.0.1)   : " routerip
  read -p "Enter subnet    (looks like 255.255.255.0) : " netmask
  read -p "Enter DNS       (looks like 192.168.0.1)   : " dns
}

writeinterfacefile()
{ 
cat << EOF > $1 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
# The loopback network interface
##auto lo
##iface lo inet loopback
# The primary network interface
auto eth0
##iface eth0 inet dhcp

#Your static network configuration  
iface eth0 inet static
address $staticip
netmask $netmask
gateway $routerip 
dns-nameservers $dns
EOF
#don't use any space before of after 'EOF' in the previous line

  echo ""
  echo "Your configuration was saved in '$1'"
  echo ""
  echo "Restarting interfaces..."
  restartNW
  exit 0
}

file="/etc/network/interfaces"
if [ ! -f $file ]; then
  echo ""
  echo "The file '$file' does not exist!"
  echo ""
  exit 1
fi

clear

IP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | cut -d: -f2`
DG=`route | grep "default" | awk '{print $2}'`

echo "Your current IP: $IP"
echo "Your current DG: $DG"
echo ""
echo "Set up a static IP address"
echo ""

getinfo
echo ""
echo "Your settings are"
echo "Static IP       :  $staticip"
echo "Default Gateway :  $routerip"
echo "Subnetmask      :  $netmask"
echo "DNS             :  $dns"
echo ""

restartNW()
{
  stopNW=`sudo ifdown eth0`
  startNW=`sudo ifup eth0`
}

while true; 
do
 read -p "Is this configuration correct? [y/n]: " yn 
  case $yn in
    [Yy]* ) writeinterfacefile $file;;
    [Nn]* ) getinfo;;
        * ) echo "Please enter y or n!";;
  esac
done
