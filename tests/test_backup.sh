#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

export HOME="$TMP_DIR/home"
mkdir -p "$HOME"

STUB_DIR="$TMP_DIR/stubs"
mkdir -p "$STUB_DIR"

cat <<'STUB' > "$STUB_DIR/gh"
#!/usr/bin/env bash
if [ "${1:-}" = "repo" ] && [ "${2:-}" = "list" ]; then
  printf '%s\n' "repo-one" "repo-two"
  exit 0
fi
exit 0
STUB
chmod +x "$STUB_DIR/gh"

cat <<'STUB' > "$STUB_DIR/git"
#!/usr/bin/env bash
set -e
if [ "${1:-}" = "clone" ]; then
  dest=""
  for arg in "$@"; do
    dest="$arg"
  done
  mkdir -p "$dest"
  exit 0
fi
if [ "${1:-}" = "-C" ]; then
  exit 0
fi
exit 0
STUB
chmod +x "$STUB_DIR/git"

cat <<'STUB' > "$STUB_DIR/ssh"
#!/usr/bin/env sh
exit 0
STUB
chmod +x "$STUB_DIR/ssh"

export PATH="$STUB_DIR:$PATH"

"$ROOT_DIR/src/backup.sh" --log

if [ ! -f "$ROOT_DIR/logs/backup.log" ]; then
  printf '%s\n' "Expected log file not found" >&2
  exit 1
fi

if [ ! -d "$HOME/github-backups/repo-one" ] && [ ! -d "$HOME/github-backups/repo-one.git" ]; then
  printf '%s\n' "Expected backup directory not created" >&2
  exit 1
fi

printf '%s\n' "test_backup.sh: OK"
