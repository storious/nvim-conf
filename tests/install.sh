#!/bin/sh
# Offline integration tests with mocked download and replacement failures.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/fixture/repo/lua/core" "$test_root/fixture/repo/lua/plugins" "$test_root/bin"
for file in init.lua lua/core/ui.lua lua/plugins/init.lua nvim-pack-lock.json; do
  printf 'fixture\n' > "$test_root/fixture/repo/$file"
done
export TEST_ARCHIVE="$test_root/config.tar.gz"
tar -czf "$TEST_ARCHIVE" -C "$test_root/fixture" repo
cat > "$test_root/bin/curl" <<'MOCK'
#!/bin/sh
[ "${FAIL_DOWNLOAD:-0}" = 0 ] || exit 22
while [ "$#" -gt 0 ]; do
  if [ "$1" = -o ]; then cp "$TEST_ARCHIVE" "$2"; exit; fi
  shift
done
exit 1
MOCK
export REAL_MV=$(command -v mv)
cat > "$test_root/bin/mv" <<'MOCK'
#!/bin/sh
case "$1" in
  */.nvim-install.*/config) [ "${FAIL_MOVE:-0}" = 0 ] || exit 1 ;;
esac
exec "$REAL_MV" "$@"
MOCK
chmod +x "$test_root/bin/curl" "$test_root/bin/mv"
export PATH="$test_root/bin:$PATH"
export XDG_CONFIG_HOME="$test_root/config with spaces"
export NVIM_APPNAME=test-nvim
target="$XDG_CONFIG_HOME/$NVIM_APPNAME"
sh "$repo/install.sh"
test -f "$target/init.lua"
printf 'preserve me\n' > "$target/local.txt"
sh "$repo/install.sh"
test ! -e "$target/local.txt"
test -f "$target".backup-*/local.txt
printf 'must survive\n' > "$target/keep.txt"
if FAIL_DOWNLOAD=1 sh "$repo/install.sh"; then exit 1; fi
test -f "$target/keep.txt"
if FAIL_MOVE=1 sh "$repo/install.sh"; then exit 1; fi
test -f "$target/keep.txt"
rm "$test_root/fixture/repo/init.lua"
tar -czf "$TEST_ARCHIVE" -C "$test_root/fixture" repo
if sh "$repo/install.sh"; then exit 1; fi
test -f "$target/keep.txt"
if NVIM_APPNAME=../unsafe sh "$repo/install.sh"; then exit 1; fi
for stage in "$XDG_CONFIG_HOME"/.nvim-install.*; do test ! -e "$stage"; done
printf '%s\n' 'PASS: fresh install, backup, replacement, download failure, rollback, invalid archive, path validation'
