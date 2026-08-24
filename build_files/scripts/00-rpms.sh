#!/bin/bash
# ============================================================================
#  00-rpms.sh — instala RPMs locais de /ctx/files/rpm/.
# ----------------------------------------------------------------------------
#  Os arquivos *.rpm ficam em build_files/files/rpm/ e NÃO são versionados
#  (.gitignore interno). Podem ser vários. Se a pasta estiver vazia (CI,
#  clones), o script apenas ignora — não falha.
# ============================================================================
set -ouex pipefail

shopt -s nullglob
RPMS=(/ctx/files/rpm/*.rpm)

if [[ ${#RPMS[@]} -eq 0 ]]; then
    echo "Nenhum RPM local em /ctx/files/rpm/ — pulando."
    exit 0
fi

echo "Instalando ${#RPMS[@]} RPM(s) local(is):"
printf '  %s\n' "${RPMS[@]}"
dnf5 install --setopt=tsflags=nodocs -y "${RPMS[@]}"