#!/usr/bin/env bash
set -euo pipefail

sudoers_dir="/private/etc/sudoers.d"
sudoers_file="${sudoers_dir}/yabai"
tmp_file="$(mktemp)"
dry_run=false

cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: setup-yabai-sudoers.sh [--dry-run]
Options:
  --dry-run   Print and validate generated sudoers entry without writing file
  -h, --help  Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    dry_run=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Error: unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

yabai_path="$(command -v yabai || true)"
if [[ -z "$yabai_path" ]]; then
  echo "Error: yabai not found in PATH" >&2
  exit 1
fi

yabai_sha="$(shasum -a 256 "$yabai_path" | awk '{print $1}')"
user_name="$(whoami)"
entry="${user_name} ALL=(root) NOPASSWD: sha256:${yabai_sha} ${yabai_path} --load-sa"

printf '%s\n' "$entry" >"$tmp_file"

if ! sudo visudo -cf "$tmp_file"; then
  echo "Error: generated sudoers entry is invalid." >&2
  exit 1
fi

if [[ "$dry_run" == true ]]; then
  echo "Dry run successful. Generated entry:"
  printf '%s\n' "$entry"
  exit 0
fi

sudo install -d -m 0755 "$sudoers_dir"
sudo install -m 0440 "$tmp_file" "$sudoers_file"

echo "Installed and validated: $sudoers_file"
