# AGENTS.md

Repositório **bootc** (Universal Blue image-template) que gera o "WiseLinux" — Fedora 44 base + KDE Plasma + customizações. Respostas devem estar em **pt-BR**.

## Arquitetura / fluxo de build

- `Containerfile` é uma **casca fina**: não instala nada inline. Estágio `ctx` (scratch) copia `build_files/`, `system_files/` e os expõe como bind mount em `/ctx` durante o build (não vão para a imagem final). O build real roda `/ctx/build.sh`.
- `build_files/build.sh` é o **orquestrador** (padrão ublue/bos/bluefin): derrama `system_files/` na raiz, cria symlinks `/opt`→`/var/opt` e `/usr/local`→`/var/usrlocal` (necessários pois `/usr` é read-only no OSTree) e roda, em ordem alfabética, os **scripts numerados** de `build_files/scripts/`:
  - `00-rpms.sh` — instala RPMs locais de `build_files/files/rpm/` (gitignored; pode haver vários; pasta vazia não falha)
  - `01-packages.sh` — RPM Fusion + repos de apps (COPRs/Microsoft) habilitados temporariamente; instala `base.txt`/`app.txt`/`kde.txt`, remove `removed.txt`, desabilita os repos de terceiros e roda `dnf5 clean all`
  - `02-branding.sh` — identidade os-release → WiseLinux
  - `03-services.sh` — `systemctl enable`/`mask` + `firewall-offline-cmd`
  - `04-cleanup.sh` — higiene bootc conservadora
  - `06-cosign.sh` — baixa e instala o CLI `cosign` (sigstore) em `/usr/local/bin` (não está nos repos Fedora; binário estático Go via GitHub Releases)
  - `validate-repos.sh` — falha se houver repo de terceiros habilitado além de Fedora/RPM Fusion (usa `dnf5 repo list --json` + python3)
  - `20-tests.sh` — valida branding, pacotes presentes/ausentes e serviços habilitados; falha aborta o build
- **Listas declarativas de pacotes** (edite estas, não os scripts):
  - `build_files/base.txt` — pacotes nativos de sistema
  - `build_files/app.txt` — apps de repos de terceiros (VSCode Microsoft, yazi, vm-curator, JetBrains Mono, Firefox pt-BR)
  - `build_files/kde.txt` — pacote KDE/Plasma
  - `build_files/removed.txt` — pacotes a remover (ex.: mariadb, PackageKit)
  - RPMs locais (TOTVS Web Agent etc.) vão em `build_files/files/rpm/` (pasta `.gitignore`d; instalação pelo `00-rpms.sh`)
  - Não há mais lista de flatpaks: o bootstrap de Flatpaks (`post-install.service`) foi removido por enquanto.
- **Discover/Flatpak (padrão RYnux):** o Discover é "Flathub puro". `removed.txt` tira `PackageKit` (some o backend RPM do Discover) e `fedora-flathub-remote`; `04-cleanup.sh` remove `flatpak-add-fedora-repos.service` (que re-adicionaria os remotos "Fedora Flatpaks" `fedora`/`fedora-testing` via oci no 1º boot). O Flathub vem como remoto do sistema via `system_files/etc/flatpak/remotes.d/flathub.flatpakrepo` (baixado de `https://dl.flathub.org/repo/flathub.flatpakrepo`). Assim o usuário vê só "Flathub" no Discover; `wise-flatpaks.sh` cria seu próprio remoto flathub `--user` (escopo root) no 1º boot apenas para os installs de apps (Brave, Telegram, Remmina, KeePassXC).
- `system_files/` espelha a árvore final do sistema (`etc/`, `usr/`) e é copiada intacta para a raiz.

## Build e build de imagens de disco (via `just`)

- `image-template.env` fornece as variáveis (`IMAGE_NAME`, `REPO_ORGANIZATION`, `DEFAULT_TAG`, `BIB_IMAGE`). O `Justfile` carrega via `dotenv`.
- `just build` — build do container com podman. CI chama `sudo just build` (root) porque `ostree-rechunk` exige root e os artefatos precisam estar no storage rootful do podman.
- `just ostree-rechunk <img> <tag>` — rechunk clássico com rpm-ostree (**exige root**). `just rechunk` — novo chunkah.
- Imagens de disco (BIB/bootc-image-builder): `just build-qcow2`, `just build-raw`, `just build-iso`, e variantes `rebuild-*` / `run-vm-*`. Resultados vão em `output/`.
- **Importante (Justfile `_build-bib`):** o `--rootfs=btrfs` é passado **apenas** para qcow2/raw, **nunca para iso**. Para ISO o particionamento vem do kickstart em `disk_config/iso.toml` (Btrfs com subvolumes root/var/home/flatpak/etc). Passar `--rootfs` no ISO faz o BIB sobrepor o kickstart (bug conhecido de root+home). `disk_config/disk.toml` é só o rootfs btrfs padrão.
- `just lint` — shellcheck (exige `shellcheck` instalado). `just format` — shfmt. `just check`/`just fix` — sintaxe dos `.just`/Justfile.

## CI (GitHub Actions)

- `build.yml` — build do container, rechunk, push GHCR, assinatura cosign (`SIGNING_SECRET`) e notificação por **GitHub Issue** (feed) em vez de email SMTP. Cron diário 10:05 UTC.
- `build-disk.yml` — gera qcow2 e anaconda-iso via `bootc-image-builder-action`. Manual (`workflow_dispatch`) ou em PR que toque `disk_config/` ou o workflow. Usa `disk_config/iso.toml` para iso, `disk.toml` para qcow2. Push/S3 opcional via secrets rclone.
- Imagem publicada: `ghcr.io/<org>/wiselinux:latest` (regras: `IMAGE_REGISTRY` e `IMAGE_NAME` são lowercased no CI; `REPO_ORGANIZATION`/`IMAGE_NAME` ainda vazios no `image-template.env` até criar o novo repositório).

## Gotchas / convenções

- `cosign.key` **nunca** deve ser commitado (está no `.gitignore`); apenas `cosign.pub` e o secret `SIGNING_SECRET` no GitHub.
- A base `fedora-bootc:44` está **pinada** — não trocar para `:latest` sem decisão consciente.
- `dnf5 clean all` é chamado no fim do `01-packages.sh`; não adicionar `dnf clean` nas RUNs (cache é bind-mount persistente, tmpfs em /tmp).
- Ao adicionar novo passo de build: crie um **script numerado** em `build_files/scripts/` (ex.: `05-*.sh`) em vez de mexer no `build.sh`; o build.sh já roda todos em ordem + validações no fim.
- Não usar `bootc container lint` inline fora do Containerfile (já roda como etapa final).
- Este repositório local **não é um repo git** (não há `.git`). `TASK.md` registra decisões/estado de tarefas — ler antes de mexer em CI/notificações.
