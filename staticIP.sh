#!/bin/bash
#This is a bash script to set a static IP. (Ubuntu)

readInfo()
{
  read -p "Enter static IP (eg: 192.168.0.105) : " staticip  
  read -p "Enter DefGw     (eg: 192.168.0.1)   : " gateway
  read -p "Enter subnet    (eg: 255.255.255.0) : " netmask
  read -p "Enter DNS       (eg: 192.168.0.1)   : " dns
}

writeToIntf()
{ 
cat << EOF > $1 
# This file describes the network interfaces available on your system.
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
gateway $gateway
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

restartNW()
{
  stopNW=`sudo ifdown eth0`
  startNW=`sudo ifup eth0`
}

#Add your path here
file="/etc/network/interfaces"
if [ ! -f $file ]; then
  echo ""
  echo "The file '$file' does not exist!"
  echo ""
  exit 1
fi

clear

IP=`hostname -I`
DG=`route | grep "default" | awk '{print $2}'`

echo "Your current IP: $IP"
echo "Your current DG: $DG"
echo ""
echo "Set up a static IP address"
echo ""

readInfo
echo ""
echo "Your settings are"
echo "Static IP       :  $staticip"
echo "Default Gateway :  $gateway"
echo "Subnetmask      :  $netmask"
echo "DNS             :  $dns"
echo ""

while true; 
do
 read -p "Is this configuration correct? [y/n]: " yn 
  case $yn in
    [Yy]* ) writeToIntf $file;;
    [Nn]* ) readInfo;;
        * ) echo "Enter y or n!";;
  esac
done
