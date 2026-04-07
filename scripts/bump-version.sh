#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "error: .version-bump.json not found" >&2
  exit 1
fi

read_json_field() {
  local file="$1" field="$2"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./' | sed 's/\.\././g')
  jq -r "$jq_path" "$file"
}

write_json_field() {
  local file="$1" field="$2" value="$3"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./' | sed 's/\.\././g')
  local tmp="${file}.tmp"
  jq "$jq_path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
}

check_versions() {
  echo "Current versions:"
  local count
  count=$(jq '.files | length' "$CONFIG")
  for ((i=0; i<count; i++)); do
    local fpath field ver
    fpath=$(jq -r ".files[$i].path" "$CONFIG")
    field=$(jq -r ".files[$i].field" "$CONFIG")
    ver=$(read_json_field "$REPO_ROOT/$fpath" "$field")
    printf "  %-45s %s\n" "$fpath ($field)" "$ver"
  done
}

bump_versions() {
  local new_version="$1"
  echo "Bumping to $new_version ..."
  local count
  count=$(jq '.files | length' "$CONFIG")
  for ((i=0; i<count; i++)); do
    local fpath field
    fpath=$(jq -r ".files[$i].path" "$CONFIG")
    field=$(jq -r ".files[$i].field" "$CONFIG")
    write_json_field "$REPO_ROOT/$fpath" "$field" "$new_version"
    echo "  ✓ $fpath"
  done
  echo "Done."
}

case "${1:-}" in
  --check) check_versions ;;
  --help|-h|"")
    echo "Usage: bump-version.sh <new-version> | --check"
    ;;
  *) bump_versions "$1" ;;
esac
