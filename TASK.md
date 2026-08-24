# TASK: rebranding + limpeza pré-publicação

> Created: 2026-08-24

## Contexto
Repositório local (não é git) antes chamado "JobWise Linux". Decisão: renomear
para **WiseLinux**, remover referências ao GitHub (novo repositório será criado
mais tarde) e remover o bootstrap de Flatpaks (`post-install`).

## Mudanças feitas
- Renomeado tudo de `jobwise*`/`JobWise` para `wise*`/`Wise` (nomes de exibição
  e internos: serviços `wise-*.service`, dirs `/usr/share/wise`, `/var/lib/wise`,
  perfil Konsole `Wise.profile`).
- Removido `post-install.service`, `post-install.sh` e `build_files/flatpak.txt`
  (bootstrap de Flatpaks desativado por enquanto) e o setup de Flathub no build.sh.
- Removida a pasta `setup/` inteira (scripts user-space: homebrew,
  microsoft-fonts, distrobox-dev-totvs, oh-my-zsh, zsh) e o executor
  `wise-setup` + serviço `wise-oh-my-zsh` (referência quebrada para
  `/usr/libexec/wise/setup/`).
- Removido tudo de zsh: serviço `wise-set-zsh.service`, `wise-set-zsh.sh`,
  enable no `03-services.sh`, teste no `20-tests.sh` e as configs system-wide
  (`/usr/share/wise/zshrc.zsh`, `p10k.zsh`).
- `build.sh`: branding `PRETTY_NAME="WiseLinux (Fedora)"`; removidas URLs de
  os-release do GitHub.
- `image-template.env`: `IMAGE_NAME=wiselinux`; `REPO_ORGANIZATION` e
  `IMAGE_LOGO_URL` vazios (preencher ao criar o novo repositório).

## Melhorias (padrão ublue/bos/bluefin)
- `build.sh` agora é só orquestrador: contexto (system_files + symlinks) + loop
  de **scripts numerados** em `build_files/scripts/`:
  - `01-packages.sh` — RPM Fusion, install base/kde.txt, remove removed.txt, clean
  - `02-branding.sh` — os-release → WiseLinux (estrutura espelhada do RYnux:
    NAME + PRETTY_NAME + HOME/DOCUMENTATION/SUPPORT/BUG_URL; URLs placeholder)
  - `03-services.sh` — systemctl enable/mask + firewall kdeconnect
  - `04-cleanup.sh` — higiene bootc
  - `validate-repos.sh` — falha se repo de terceiros habilitado (dnf5 json + python3)
  - `20-tests.sh` — valida branding/pacotes/serviços; falha aborta o build
- Gotcha: `20-tests.sh` é excluído do loop do build.sh (chamado explicitamente no fim).
- Documentado em AGENTS.md.

## Pending
- Criar o novo repositório e preencher `REPO_ORGANIZATION`/`IMAGE_LOGO_URL` no
  `image-template.env`.
- Definir/recriar o `.github/workflows` para o novo repo (notificação atual via
  GitHub Issue em `build.yml`).
