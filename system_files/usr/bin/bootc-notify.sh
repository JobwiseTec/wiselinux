#!/bin/bash
# Avisa, no login interativo, se há atualização bootc aplicada aguardando reboot.
# Chamado por /etc/profile.d/bootc-notify.sh.
if [ -f /run/reboot-required ]; then
    echo -e "\e[1;36m🔄 Atualização pendente, reinicie para aplicação.\e[0m"
fi
