#!/usr/bin/env bash

repo_url() {
  printf 'git@github.com:%s/%s.git' "$GITHUB_USERNAME" "$1"
}

clone_repo() {
  repo="$1"
  if [ -z "$repo" ]; then
    printf '%s\n' "clone_repo: missing repository name" >&2
    return 1
  fi

  case "$CLONE_MODE" in
    normal)
      git clone "$(repo_url "$repo")" "$BACKUP_DIR/$repo"
      ;;
    mirror)
      git clone --mirror "$(repo_url "$repo")" "$BACKUP_DIR/$repo.git"
      ;;
    *)
      printf '%s\n' "Invalid CLONE_MODE: $CLONE_MODE (expected normal or mirror)" >&2
      return 1
      ;;
  esac
}

update_repo() {
  repo="$1"
  if [ -z "$repo" ]; then
    printf '%s\n' "update_repo: missing repository name" >&2
    return 1
  fi

  case "$CLONE_MODE" in
    normal)
      git -C "$BACKUP_DIR/$repo" fetch --all
      ;;
    mirror)
      git -C "$BACKUP_DIR/$repo.git" remote update
      ;;
    *)
      printf '%s\n' "Invalid CLONE_MODE: $CLONE_MODE (expected normal or mirror)" >&2
      return 1
      ;;
  esac
}
