#!/bin/bash
# Tento skript slouzi k odpojeni stanice eduxo VPS-LabX od ZeroTier VPN site VPS-LabX

# Odpojeni do VPN site VPS-LabX
echo -e '\n\e[0;92mOdpojuji od VPN site VPS-LabX\e[0m'
sudo zerotier-cli leave c075fcef7ece6a93
sudo systemctl restart zerotier-one.service
sleep 3
echo -e '\n\e[1;92mHotovo!\e[0m'
