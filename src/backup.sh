#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_FILE="$ROOT_DIR/config/config.env"
LOG_FILE="$ROOT_DIR/logs/backup.log"

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
touch "$LOG_FILE"

# Send all output to the log file.
exec >>"$LOG_FILE" 2>&1

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
