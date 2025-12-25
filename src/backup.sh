#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_FILE="$ROOT_DIR/config/config.env"
LOG_FILE="$ROOT_DIR/logs/backup.log"

print_banner() {
  cat <<'BANNER'
   ___         __              ____             __             
  /   | __  __/ /_____        / __ )____ ______/ /____  ______ 
 / /| |/ / / / __/ __ \______/ __  / __ `/ ___/ //_/ / / / __ \
/ ___ / /_/ / /_/ /_/ /_____/ /_/ / /_/ / /__/ ,< / /_/ / /_/ /
/_/  |_\__,_/\__/\____/     /_____/\__,_/\___/_/|_|\__,_/ .___/ 
                                                      /_/      
BANNER
}

LOG_TO_FILE=0
if [ "${1:-}" = "--log" ]; then
  LOG_TO_FILE=1
  shift
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  printf '%s\n' "Usage: $0 [--log]"
  printf '%s\n' "  --log   Write output to logs/backup.log instead of stdout"
  exit 0
elif [ "$#" -gt 0 ]; then
  printf '%s\n' "Unknown option: $1" >&2
  printf '%s\n' "Usage: $0 [--log]" >&2
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  printf '%s\n' "Missing config file: $CONFIG_FILE" >&2
  exit 1
fi

. "$ROOT_DIR/src/logger.sh"
. "$ROOT_DIR/src/requirements.sh"
. "$ROOT_DIR/src/github_api.sh"
. "$ROOT_DIR/src/git_ops.sh"
. "$CONFIG_FILE"

mkdir -p "$ROOT_DIR/logs"
if [ "$LOG_TO_FILE" -eq 1 ]; then
  touch "$LOG_FILE"
  # Send all output to the log file.
  exec >>"$LOG_FILE" 2>&1
fi

print_banner

log "Starting GitHub AutoBackup"
check_requirements

if [ -z "${GITHUB_USERNAME:-}" ] || [ -z "${BACKUP_DIR:-}" ] || [ -z "${CLONE_MODE:-}" ]; then
  log "Missing configuration values in $CONFIG_FILE"
  exit 1
fi

case "$CLONE_MODE" in
  normal|mirror)
    ;;
  *)
    log "Invalid CLONE_MODE: $CLONE_MODE (expected normal or mirror)"
    exit 1
    ;;
esac

mkdir -p "$BACKUP_DIR"

repos="$(get_repos)"
if [ -z "$repos" ]; then
  log "No repositories found for $GITHUB_USERNAME"
  exit 0
fi

log "Repositories found: $repos"

for repo in $repos; do
  if [ "$CLONE_MODE" = "mirror" ]; then
    repo_dir="$BACKUP_DIR/$repo.git"
  else
    repo_dir="$BACKUP_DIR/$repo"
  fi

  if [ -d "$repo_dir" ]; then
    log "Updating $repo (existing clone)"
    update_repo "$repo"
  else
    log "Cloning $repo (not found locally)"
    clone_repo "$repo"
  fi
done

log "Backup completed"
