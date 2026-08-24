#!/bin/bash
# ============================================================================
#  WISELINUX — build.sh (orquestrador)
# ----------------------------------------------------------------------------
#  Casca fina: NÃO contém lógica de pacotes/config. Apenas prepara o contexto
#  (system_files + symlinks) e roda, EM ORDEM, os scripts numerados de
#  build_files/scripts/ (padrão ublue/bos/bluefin).
#
#  Listas declarativas de pacotes (edite estas, não os scripts):
#    build_files/base.txt    → pacotes nativos a instalar
#    build_files/kde.txt     → pacotes KDE/Plasma
#    build_files/removed.txt → pacotes a remover da base
#
#  Roda dentro do build com /ctx (bind do contexto), cache em /var/cache e
#  /var/log, tmpfs em /tmp.
# ============================================================================
set -ouex pipefail

# ============================================================================
#  Contexto — system_files/ espelha a árvore final do sistema (etc, usr) →
#  derrama na raiz.
# ============================================================================
cp -avf /ctx/system_files/. /

# /usr é read-only no OSTree. /opt e /usr/local precisam apontar p/ /var.
mkdir -vp /var/roothome /var/home /data

rm -rvf /opt && mkdir -vp /var/opt && ln -vs /var/opt /opt

mkdir -vp /var/usrlocal
( mv -v /usr/local/* /var/usrlocal/ 2>/dev/null || true )
rm -rvf /usr/local && ln -vs /var/usrlocal /usr/local

# ============================================================================
#  Scripts numerados — rodam em ordem alfabética (01, 02, ... 04).
#  validate-repos.sh e 20-tests.sh são chamados explicitamente no fim.
# ============================================================================
for script in /ctx/scripts/[0-9][0-9]-*.sh; do
    case "$(basename "${script}")" in
        20-tests.sh) continue ;;  # chamado explicitamente abaixo
    esac
    echo "::group::$(basename "${script}")"
    bash "${script}"
    echo "::endgroup::"
done

# ============================================================================
#  Validações finais — não devem ser editadas à toa; são a rede de segurança
#  do build (repos inesperados habilitados + testes de conteúdo).
# ============================================================================
echo "::group::validate-repos.sh"
bash /ctx/scripts/validate-repos.sh
echo "::endgroup::"

echo "::group::20-tests.sh"
bash /ctx/scripts/20-tests.sh
echo "::endgroup::"