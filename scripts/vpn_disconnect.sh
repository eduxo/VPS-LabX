#!/bin/bash
# Tento skript slouzi k odpojeni stanice eduxo VPS-LabX od ZeroTier VPN site VPS-LabX

# Ostraneni zaznamu z /etc/network/interfaces

# Ziskani seznamu sitovych rozhrani
network_interfaces=$(ip -o link show | awk -F': ' '{print $2}')

# Projde seznam a najde zacinajici na "zt"
for interface in $network_interfaces; do
  if [[ $interface == zt* ]]; then
    # Ziskani IP adresy a masky pro ZT rozhrani
    ip_info=$(ip -o -f inet addr show dev $interface | awk '{print $4}')
    
    # Extrahujte IP adresu a masku ze ziskanych informaci
    ip_address=$(echo $ip_info | cut -d'/' -f1)
    cidr_mask=$(echo $ip_info | cut -d'/' -f2)
    
    # Vytvori CIDR notaci
    cidr_notation="$ip_address/$cidr_mask"

sudo sh -c 'echo "
# Interface for ZeroTier
iface '$interface' inet manual

auto vmbr1
iface vmbr1 inet static
	address '$cidr_notation'
        bridge-ports '$interface'
        bridge-stp off
        bridge-fd 0
        bridge-maxwait 3
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '\''10.20.30.0/24'\'' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '\''10.20.30.0/24'\'' -o vmbr0 -j MASQUERADE
" > text'
text_to_remove=text

# Cesta k souboru interfaces
interfaces_file="/etc/network/interfaces"

# Odstraneni textu ze souboru interfaces
sudo sed -i "/^# Interface for ZeroTier/,/^post-down iptables -t nat -D POSTROUTING -s '10.20.30.0\/24' -o vmbr0 -j MASQUERADE/d" $interfaces_file

    break
  fi
done


# Odpojeni do VPN site VPS-LabX
echo -e '\n\e[0;92mOdpojuji od VPN site VPS-LabX\e[0m'

sudo zerotier-cli leave c075fcef7ece6a93
sudo systemctl restart zerotier-one.service
sleep 3

echo -e '\n\e[0;92mRestartuji sit\e[0m'
sleep 3
sudo systemctl restart networking
echo -e '\e[1;92mHotovo!\e[0m'

