#!/bin/bash
# ============================================================================
#  01-packages.sh — repositórios, instalação e remoção de pacotes.
# ----------------------------------------------------------------------------
#  Usa as listas declarativas (edite estas, não os scripts):
#    /ctx/base.txt    → pacotes nativos a instalar
#    /ctx/kde.txt     → pacotes KDE/Plasma
#    /ctx/removed.txt → pacotes a remover da base
# ============================================================================
set -ouex pipefail

# ============================================================================
#  Repositórios
# ============================================================================
dnf5 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# ============================================================================
#  Pacotes — instala as listas declarativas
# ============================================================================
# Pacotes Base
sed 's/#.*//' /ctx/base.txt | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y

# Pacotes KDE
sed 's/#.*//' /ctx/kde.txt | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y

# Pacotes removidos
sed 's/#.*//' /ctx/removed.txt | tr '\n' ' ' | xargs dnf5 remove -y

dnf5 clean all