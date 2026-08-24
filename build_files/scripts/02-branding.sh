#!/bin/bash
# ============================================================================
#  02-branding.sh — identidade os-release → WiseLinux
#  Estrutura espelhada do Fedora RYnux (NAME + PRETTY_NAME + URLs).
#  URLs em placeholder até criar o repositório do WiseLinux.
# ============================================================================
set -ouex pipefail

sed -i 's/^NAME=.*/NAME="WiseLinux"/' /usr/lib/os-release
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="WiseLinux (Fedora)"/' /usr/lib/os-release
sed -i 's|^HOME_URL=.*|HOME_URL="https://github.com/JobwiseTec/wiselinux"|' /usr/lib/os-release
sed -i 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/JobwiseTec/wiselinux"|' /usr/lib/os-release
sed -i 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/JobwiseTec/wiselinux/issues"|' /usr/lib/os-release
sed -i 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/JobwiseTec/wiselinux/issues"|' /usr/lib/os-release