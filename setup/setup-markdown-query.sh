#!/usr/bin/env bash
# Minimal setup for the markdown-query Skill only.
# Installs `mdq` CLI into a local .venv.
set -u

CHECK_ONLY=false
FORCE_RECREATE_VENV=false
WITH_WATCH=false
FROM_PATH=""
WARNING_COUNT=0

usage() {
  cat <<'USAGE'
Usage: ./setup-markdown-query.sh [options]

Options:
  --check-only             Report current state without changing files.
  --force-recreate-venv    Recreate .venv if its Python is older than 3.11.
  --with-watch             Also install `watchdog` so `mdq watch` works.
  --from PATH              Install `mdq` from a local source path (pip install -e PATH) instead of PyPI.
  -h, --help               Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-only) CHECK_ONLY=true ;;
    --force-recreate-venv) FORCE_RECREATE_VENV=true ;;
    --with-watch) WITH_WATCH=true ;;
    --from) shift; FROM_PATH="${1:-}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

step() { printf '\n==> %s\n' "$1"; }
warn() { WARNING_COUNT=$((WARNING_COUNT + 1)); printf 'WARNING: %s\n' "$1" >&2; }
die()  { printf 'ERROR: %s\n' "$1" >&2; exit 1; }
run()  { printf '> '; printf '%q ' "$@"; printf '\n'; "$@" || die "Command failed: $*"; }

py_is_311() { "$1" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)' 2>/dev/null; }
find_python() {
  local c
  for c in python3 python; do
    if command -v "$c" >/dev/null 2>&1 && py_is_311 "$c"; then command -v "$c"; return 0; fi
  done
  return 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"
VENV_PY="${VENV_DIR}/bin/python"

cd "$REPO_ROOT" || exit 1

step "Checking Python 3.11+"
PY_BIN=""
if PY_BIN="$(find_python)"; then
  printf 'Python: %s\n' "$PY_BIN"
else
  warn "Python 3.11+ not found. Install it and rerun."
  [[ "$CHECK_ONLY" == true ]] || exit 1
fi

step "Checking .venv"
if [[ -x "$VENV_PY" ]]; then
  if py_is_311 "$VENV_PY"; then
    printf 'Existing .venv: OK\n'
  elif [[ "$FORCE_RECREATE_VENV" == true && "$CHECK_ONLY" != true ]]; then
    warn ".venv is older than 3.11. Recreating."
    rm -rf "$VENV_DIR"
  else
    warn ".venv is older than 3.11. Rerun with --force-recreate-venv."
    [[ "$CHECK_ONLY" == true ]] || exit 1
  fi
elif [[ "$CHECK_ONLY" == true ]]; then
  warn ".venv not found. Run without --check-only to create it."
fi

if [[ "$CHECK_ONLY" != true && ! -x "$VENV_PY" ]]; then
  [[ -n "$PY_BIN" ]] || die "Python 3.11+ required."
  run "$PY_BIN" -m venv "$VENV_DIR"
fi

if [[ -x "$VENV_PY" && "$CHECK_ONLY" != true ]]; then
  step "Installing mdq"
  run "$VENV_PY" -m pip install --upgrade pip
  if [[ -n "$FROM_PATH" ]]; then
    run "$VENV_PY" -m pip install -e "$FROM_PATH"
  else
    if ! "$VENV_PY" -m pip install --upgrade mdq; then
      warn "Failed to install 'mdq' from PyPI. If the package is not yet published, use: --from /path/to/mdq"
    fi
  fi
  if [[ "$WITH_WATCH" == true ]]; then
    run "$VENV_PY" -m pip install --upgrade watchdog
  fi
fi

if [[ -x "$VENV_PY" ]]; then
  step "Verifying mdq"
  if "$VENV_PY" -m mdq --help >/dev/null 2>&1; then
    printf 'mdq --help: OK\n'
  else
    warn "'python -m mdq --help' failed. mdq is not installed."
  fi
  if [[ "$WITH_WATCH" == true ]]; then
    if "$VENV_PY" -c 'import watchdog' >/dev/null 2>&1; then
      printf 'watchdog: OK\n'
    else
      warn "watchdog not importable."
    fi
  fi
fi

step "Next steps"
if [[ -x "$VENV_PY" ]]; then
  printf '  %s -m mdq index\n'  "$VENV_PY"
  printf '  %s -m mdq stats\n'  "$VENV_PY"
  printf '  %s -m mdq search --q "your query" --top-k 5\n' "$VENV_PY"
else
  printf 'Create .venv first (rerun without --check-only).\n'
fi

printf '\nCompleted with %s warning(s).\n' "$WARNING_COUNT"
