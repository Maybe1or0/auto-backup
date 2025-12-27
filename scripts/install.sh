#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
CURRENT_USER=${SUDO_USER:-$USER}

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    printf '%s\n' "This script requires root privileges to install systemd units." >&2
    exit 1
  fi
fi

missing_cmds=""
for cmd in git gh ssh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing_cmds="$missing_cmds $cmd"
  fi
done

if [ -n "$missing_cmds" ]; then
  if command -v apt-get >/dev/null 2>&1; then
    pkgs=""
    for cmd in $missing_cmds; do
      case "$cmd" in
        git) pkgs="$pkgs git" ;;
        gh) pkgs="$pkgs gh" ;;
        ssh) pkgs="$pkgs openssh-client" ;;
      esac
    done
    $SUDO apt-get update
    $SUDO apt-get install -y $pkgs
  else
    printf '%s\n' "Missing dependencies:$missing_cmds" >&2
    printf '%s\n' "Install them manually and re-run this script." >&2
    exit 1
  fi
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  printf '%s\n' "GitHub CLI not authenticated. Run: gh auth login" >&2
  exit 1
fi

SERVICE_TEMPLATE="$ROOT_DIR/systemd/github-autobackup.service"
TIMER_TEMPLATE="$ROOT_DIR/systemd/github-autobackup.timer"
SERVICE_DST="/etc/systemd/system/github-autobackup.service"
TIMER_DST="/etc/systemd/system/github-autobackup.timer"

tmp_service="$(mktemp)"
sed "s|__PROJECT_ROOT__|$ROOT_DIR|g; s|__BACKUP_USER__|$CURRENT_USER|g" \
  "$SERVICE_TEMPLATE" > "$tmp_service"

$SUDO install -m 644 "$tmp_service" "$SERVICE_DST"
$SUDO install -m 644 "$TIMER_TEMPLATE" "$TIMER_DST"
rm -f "$tmp_service"

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now github-autobackup.timer

printf '%s\n' "Installation complete. Edit config/config.env before running."
