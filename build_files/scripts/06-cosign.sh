#!/bin/bash
# ============================================================================
#  06-cosign.sh — instala o CLI cosign (sigstore) na imagem.
# ----------------------------------------------------------------------------
#  cosign não está nos repositórios Fedora/RPM Fusion; é um binário estático
#  Go distribuído via GitHub Releases (Chainguard). Baixa a versão "latest"
#  para x86_64 e instala em /usr/bin.
# ============================================================================
set -ouex pipefail

curl -fsSLo /usr/local/bin/cosign \
    "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"

chmod +x /usr/local/bin/cosign