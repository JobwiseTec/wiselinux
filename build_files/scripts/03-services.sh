#!/bin/bash
# ============================================================================
#  03-services.sh — serviços, Plymouth e firewall
# ----------------------------------------------------------------------------
#  Roda DEPOIS dos installs (01-packages.sh): firewall-offline-cmd exige o
#  pacote firewalld já presente (via base.txt).
# ============================================================================
set -ouex pipefail

systemctl enable libvirtd                  # virtualização
systemctl mask systemd-remount-fs.service  # evita erro visual inofensivo no boot

# Libera kdeconnect no firewall.
firewall-offline-cmd --add-service=kdeconnect