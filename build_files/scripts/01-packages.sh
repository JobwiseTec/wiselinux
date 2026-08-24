#!/bin/bash
# ============================================================================
#  01-packages.sh — repositórios, instalação e remoção de pacotes.
# ----------------------------------------------------------------------------
#  Usa as listas declarativas (edite estas, não os scripts):
#    /ctx/base.txt    → pacotes nativos a instalar
#    /ctx/app.txt     → apps de repos de terceiros (habilitados temporariamente)
#    /ctx/kde.txt     → pacotes KDE/Plasma
#    /ctx/removed.txt → pacotes a remover da base
# ============================================================================
set -ouex pipefail

# ============================================================================
#  Repositórios
# ============================================================================
# RPM Fusion
dnf5 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Repos de terceiros para apps — habilitados TEMPORARIAMENTE e desabilitados
# no fim deste script (validate-repos.sh exige imagem final só com Fedora+Fusion).
FEDORA="$(rpm -E %fedora)"

# COPR yazi (gerenciador de arquivos)
curl -fsSLo /etc/yum.repos.d/_copr_lihaohong-yazi.repo \
    "https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-${FEDORA}/"

# COPR vm-curator (máquinas virtuais)
curl -fsSLo /etc/yum.repos.d/_copr_lgl-vm-curator.repo \
    "https://copr.fedorainfracloud.org/coprs/linuxgamerlife/lgl-vm-curator/repo/fedora-${FEDORA}/"

# COPR jetbrains-mono-fonts
curl -fsSLo /etc/yum.repos.d/_copr_elxreno-jetbrains-mono-fonts.repo \
    "https://copr.fedorainfracloud.org/coprs/elxreno/jetbrains-mono-fonts/repo/fedora-${FEDORA}/"

# Repo oficial Microsoft (Visual Studio Code)
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat > /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# ============================================================================
#  Pacotes — instala as listas declarativas
# ============================================================================
# Pacotes Base
sed 's/#.*//' /ctx/base.txt | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y

# Pacotes de apps (repos de terceiros)
sed 's/#.*//' /ctx/app.txt | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y

# Pacotes KDE
sed 's/#.*//' /ctx/kde.txt | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y

# Pacotes removidos
sed 's/#.*//' /ctx/removed.txt | tr '\n' ' ' | xargs dnf5 remove -y

# ============================================================================
#  Desabilita os repos de terceiros (imagem final limpa) e limpa o cache
# ============================================================================
sed -i 's/^enabled=1/enabled=0/' \
    /etc/yum.repos.d/_copr_lihaohong-yazi.repo \
    /etc/yum.repos.d/_copr_lgl-vm-curator.repo \
    /etc/yum.repos.d/_copr_elxreno-jetbrains-mono-fonts.repo \
    /etc/yum.repos.d/vscode.repo

dnf5 clean all