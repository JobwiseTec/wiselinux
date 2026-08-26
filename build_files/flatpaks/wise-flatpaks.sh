#!/bin/bash
# ============================================================================
#  wise-flatpaks.sh — instala flatpaks do Flathub no 1º boot (modo --user).
#  Chamado por wise-flatpaks.service (ConditionFirstBoot=yes → roda 1x).
#  Idempotente: ignora apps já instalados.
# ============================================================================
set -euo pipefail

FLATPAKS=(
    com.brave.Browser        # Navegador Brave
    org.telegram.desktop     # Mensageiro Telegram
    org.remmina.Remmina      # Cliente de área de trabalho remota (RDP/VNC)
    org.keepassxc.KeePassXC  # Gerenciador de Senha
)

# Remove o serviço que re-adiciona os remotos Fedora no boot de cada usuário
# (deixa o Flathub como única fonte no Discover).
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service

# Garante o remoto Flathub no escopo do usuário
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for app in "${FLATPAKS[@]}"; do
    if ! flatpak list --user --columns=application | grep -qx "${app}"; then
        flatpak install --user --noninteractive --assumeyes flathub "${app}"
    fi
done

flatpak uninstall --unused --user --noninteractive -y 2>/dev/null || true
