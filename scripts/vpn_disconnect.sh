#!/bin/bash
# Tento skript slouzi k odpojeni stanice eduxo VPS-LabX od ZeroTier VPN site

# Odpojeni do site VPN
echo -e '\n\e[0;92mZadejte ID VPN, od ktere se chcete odpojit:\e[0m'
read NETID

echo -e '\n\e[0;92mOdpojuji od site VPN.\e[0m'
sudo zerotier-cli leave $NETID
sudo systemctl restart zerotier-one.service
sleep 3
echo -e '\n\e[1;92mHotovo!\e[0m'
