#!/bin/sh
# POSIX shell; works with macOS /bin/sh and Linux sh. No git checkout required.
set -eu

ref=${1:-main}
app_name=${NVIM_APPNAME:-nvim}
case "$app_name" in
  ''|[!a-zA-Z0-9]*|*[!a-zA-Z0-9._-]*)
    printf '%s\n' 'NVIM_APPNAME must be a simple directory name.' >&2
    exit 1 ;;
esac
config_root=${XDG_CONFIG_HOME:-"${HOME:?HOME is not set}/.config"}
case "$config_root" in
  /*) ;;
  *) printf '%s\n' 'XDG_CONFIG_HOME must be an absolute path.' >&2; exit 1 ;;
esac
for command in curl tar mktemp; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$command" >&2
    exit 1
  }
done
# Ref is part of a URL: accept ordinary branches, tags and commit hashes only.
case "$ref" in
  ''|*[!a-zA-Z0-9._/-]*) printf '%s\n' 'Invalid repository ref.' >&2; exit 1 ;;
esac

mkdir -p "$config_root"
config_root=$(cd "$config_root" && pwd -P)
target="$config_root/$app_name"
stage=$(mktemp -d "$config_root/.nvim-install.XXXXXXXX")
backup=
installed=false
cleanup() {
  result=$?
  trap - EXIT HUP INT TERM
  if [ "$installed" = false ] && [ -n "$backup" ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
    if mv "$backup" "$target"; then
      printf '%s\n' 'Previous config restored.' >&2
    else
      printf 'Restore the backup manually: %s\n' "$backup" >&2
      result=1
    fi
  fi
  case "$stage" in
    "$config_root"/.nvim-install.*) rm -rf "$stage" ;;
  esac
  exit "$result"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

printf 'Downloading storious/nvim-conf (%s)...\n' "$ref"
curl --fail --show-error --silent --location \
  "https://codeload.github.com/storious/nvim-conf/tar.gz/$ref" -o "$stage/config.tar.gz"
mkdir "$stage/config"
tar -xzf "$stage/config.tar.gz" --strip-components=1 -C "$stage/config"
for required in init.lua lua/core/ui.lua lua/plugins/init.lua nvim-pack-lock.json; do
  if [ ! -f "$stage/config/$required" ]; then
    printf 'Archive is missing %s; existing config was not changed.\n' "$required" >&2
    exit 1
  fi
done

if [ -e "$target" ] || [ -L "$target" ]; then
  backup="$target.backup-$(date +%Y%m%d-%H%M%S)-${stage##*.}"
  mv "$target" "$backup"
  printf 'Backup: %s\n' "$backup"
fi
mv "$stage/config" "$target"
installed=true
printf 'Installed: %s\n' "$target"
printf '%s\n' 'Restart Neovim. Existing plugin data is preserved; missing plugins download on first use.'
