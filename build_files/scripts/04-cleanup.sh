#!/bin/bash
# ============================================================================
#  04-cleanup.sh — limpeza final (higiene bootc conservadora)
# ----------------------------------------------------------------------------
#  /run, /tmp, /var/tmp são runtime-only → esvaziados. Em /var/lib removemos
#  SÓ arquivos soltos seguros (caches/locks que se regeneram), não diretórios.
#  Os dirs de /var que o lint aponta são resolvidos pelo 'just ostree-rechunk'.
# ============================================================================
set -ouex pipefail

rm -rf /run/* /tmp/* /var/tmp/* 2>/dev/null || true
# Flatpak puro: remove o serviço que re-adiciona os remotos "Fedora Flatpaks"
# (fedora/fedora-testing, via oci) no 1º boot — o Flathub vem no sistema via
# /etc/flatpak/remotes.d/flathub.flatpakrepo (system_files).
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service
rm -f /var/lib/dnf/system-repo.lock \
      /var/lib/authselect/checksum \
      /var/lib/systemd/catalog/database \
      /var/lib/xkb/README.compiled \
      /var/usrlocal/share/applications/mimeinfo.cache 2>/dev/null || true