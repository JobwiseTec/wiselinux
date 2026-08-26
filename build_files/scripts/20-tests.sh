#!/bin/bash
# ============================================================================
#  20-tests.sh — validações da imagem final (padrão bluefin/ublue).
#  Roda ao final do build; falha aborta o build com exit != 0.
# ============================================================================
set -ouex pipefail

fail=0

check_cmd() {
  # check_cmd "descrição" comando [args...]
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS: ${desc}"
  else
    echo "FAIL: ${desc}" >&2
    fail=1
  fi
}

check_absent() {
  # check_absent "descrição" nome_do_pacote
  local desc="$1"
  local pkg="$2"
  if rpm -q "${pkg}" >/dev/null 2>&1; then
    echo "FAIL: pacote não deveria estar presente: ${pkg} (${desc})" >&2
    fail=1
  else
    echo "PASS: ${desc}"
  fi
}

# --- Branding ---
check_cmd "os-release com branding WiseLinux" grep -q "WiseLinux" /usr/lib/os-release

# --- Pacotes-chave presentes ---
check_cmd "kitty instalado" rpm -q kitty
check_cmd "kate instalado" rpm -q kate
check_cmd "virt-manager instalado" rpm -q virt-manager
check_cmd "gh instalado" rpm -q gh
check_cmd "fira-code-fonts instalado" rpm -q fira-code-fonts
check_cmd "ffmpegthumbs instalado" rpm -q ffmpegthumbs
check_cmd "kdegraphics-thumbnailers instalado" rpm -q kdegraphics-thumbnailers

# --- Pacotes que devem ter sido removidos ---
check_absent "PackageKit removido" PackageKit
check_absent "mariadb-server removido" mariadb-server

# --- Serviços habilitados ---
check_cmd "libvirtd habilitado" systemctl is-enabled libvirtd

if [ "${fail}" -eq 1 ]; then
  echo "Falha nos testes de imagem." >&2
  exit 1
fi

echo "OK: todos os testes de imagem passaram."