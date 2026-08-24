# ============================================================================
#  WISELINUX — Containerfile (padrão ublue-os/image-template)
# ----------------------------------------------------------------------------
#  Casca fina. NÃO instala nada inline: toda a customização vive em
#    - build_files/build.sh → lógica (installs, repos, enables, tweaks)
#    - build_files/*.txt    → listas de pacotes (base, kde, removed)
#    - system_files/        → config declarativa (espelha / do sistema)
#
#  Compressão de layers (chunkah) NÃO fica aqui — roda via 'just rechunk'.
#  Geração de ISO/qcow2 via 'just build-iso' / 'just build-qcow2' (BIB).
# ============================================================================

# ----------------------------------------------------------------------------
#  Estágio 'ctx' — carrega scripts e config SEM copiar pra imagem final.
#  É só um veículo: o conteúdo é exposto via bind mount na RUN abaixo e some.
# ----------------------------------------------------------------------------
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# ----------------------------------------------------------------------------
#  BASE — tag PINADA (não ':latest') para builds reprodutíveis.
#  ':44' = Fedora 44. Trocar de release de forma consciente e testada.
# ----------------------------------------------------------------------------
FROM quay.io/fedora/fedora-bootc:44
LABEL ostree.bootable="true"
LABEL containers.bootc="1"

# ----------------------------------------------------------------------------
#  MODIFICAÇÕES — roda build.sh com mounts otimizados:
#    bind,from=ctx → /ctx (build.sh + system_files; não vai pra layer)
#    cache /var/cache, /var/log → cache persistente fora da imagem
#    tmpfs /tmp → descartado
# ----------------------------------------------------------------------------
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# ----------------------------------------------------------------------------
#  LINT — valida integridade OSTree/bootc da imagem final.
# ----------------------------------------------------------------------------
RUN bootc container lint
