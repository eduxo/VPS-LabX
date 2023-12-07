#!/bin/bash
# Tento skript slouzi k pripojeni stanice eduxo VPS-LabX k ZeroTier VPN siti

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

# Test, jestli je ZeroTier nainstalovany, pokud ne, nainstaluje se
if ! dpkg --get-selections | grep -qw zerotier;then
    echo -e '\n\e[0;92mZeroTier neni nainstalovan. Instaluji ZeroTier.\e[0m'
    curl -s https://install.zerotier.com | sudo bash
    echo -e '\e[1;92mInstalace ZeroTier je kompletni.\e[0m'
    sleep 3
fi

# Pripojeni do site VPN
echo -e '\n\e[0;92mZadejte ID VPN, ke ktere se chcete pripojit:\e[0m'
read NETID

echo -e '\n\e[0;92mPripojuji k siti VPN.\e[0m'
sudo zerotier-cli join $NETID
sudo zerotier-cli set $NETID allowDNS=1
sleep 3
echo -e '\n\e[1;92mHotovo!\e[0m'
