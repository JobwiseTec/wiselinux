#!/bin/bash
# ============================================================================
#  validate-repos.sh — garante que a imagem final não tenha repos de terceiros
#  habilitados além do esperado (Fedora + RPM Fusion).
#  Roda ao final do build, após a instalação dos pacotes.
# ============================================================================
set -ouex pipefail

# Repos permitidos na imagem final (Fedora base + RPM Fusion).
# Ajuste esta lista se adicionar outros repos de confiança.
ALLOWED=(
  "fedora"
  "fedora-updates"
  "fedora-cisco-openh264"
  "rpmfusion-free"
  "rpmfusion-free-updates"
  "rpmfusion-nonfree"
  "rpmfusion-nonfree-updates"
)

# Lista os repos habilitados via `dnf5 repo list --json` (parse mais robusto
# que a tabela, que tem cabeçalho/prefixos variáveis).
enabled=$(dnf5 repo list --enabled --json 2>/dev/null | python3 -c '
import json, sys
for repo in json.load(sys.stdin):
    if repo.get("is_enabled", True):
        print(repo["id"])
')

bad=0
for repo in ${enabled}; do
  if ! printf '%s\n' "${ALLOWED[@]}" | grep -qx "${repo}"; then
    echo "::error::Repositório não permitido habilitado na imagem: ${repo}" >&2
    bad=1
  fi
done

if [ "${bad}" -eq 1 ]; then
  echo "Falha na validação de repositórios." >&2
  exit 1
fi

echo "OK: nenhum repositório de terceiros habilitado na imagem final."