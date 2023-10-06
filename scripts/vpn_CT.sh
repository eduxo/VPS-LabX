#!/bin/bash
# Tento skript slouzi k pripojeni stanice eduxo VPS-LabX k ZeroTier VPN siti VPS-LabX

# Test internet connection
function check_internet() {
  printf "Checking if you are online...\n"
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo -e '\e[0;92mOnline. Continuing.\e[0m'
  else
    echo -e '\e[0;91mOffline. Go connect to the internet then run the script again.\e[0m'
  fi
}

check_internet

# test, jestli je ZeroTier nainstalovany, pokud ne, nainstaluje se
if ! dpkg --get-selections | grep -qw zerotier;then
    echo -e '\n\e[0;92mZeroTier neni nanistalovan. Instaluji ZeroTier.\e[0m'
    curl -s https://install.zerotier.com | sudo bash
fi

# Pripojeni do VPN site VPS-LabX
echo -e '\n\e[0;92mPripojuji k VPN siti VPS-LabX\e[0m'

sudo zerotier-cli join c075fcef7ece6a93
sudo zerotier-cli set c075fcef7ece6a93 allowDNS=1
sudo zerotier-cli status
sudo zerotier-cli listnetworks
sleep 3

# Pridani zaznamu do /etc/network/interfaces z duvodu pouziti pro CT

# Ziskani seznamu sitovych rozhrani
network_interfaces=$(ip -o link show | awk -F': ' '{print $2}')

# Projde seznam a najde zacinajici na "zt"
for interface in $network_interfaces; do
  if [[ $interface == zt* ]]; then
    sudo sh -c 'echo "
    
    iface $interface inet manual
    
    auto vmbr1
    iface vmbr1 inet dhcp
            bridge-ports $interface
            bridge-stp off
            bridge-fd 0
            bridge-maxwait 3
            post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
            post-up   iptables -t nat -A POSTROUTING -s '10.20.30.0/24' -o vmbr0 -j MASQUERADE
            post-down iptables -t nat -D POSTROUTING -s '10.20.30.0/24' -o vmbr0 -j MASQUERADE
    " >> /etc/network/interfaces'
    break
  fi
done

echo -e '\e[1;92mHotovo, system bude restartovan!\e[0m'
sleep 3
sudo reboot
