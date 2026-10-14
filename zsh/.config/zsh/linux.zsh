[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Keep browsers and Cursor from eating the machine. systemd --user only exists here.
capped() {
  local name=$1 high=$2 max=$3; shift 3
  if systemctl --user is-active --quiet "$name.service"; then
    "$@" &>/dev/null &!
  else
    systemd-run --user --quiet --collect --unit="$name" \
      -p MemoryHigh="$high" -p MemoryMax="$max" "$@"
  fi
}
ff()  { capped firefox-capped 2G 3G firefox "$@" }
cur() { capped cursor-capped 2G 2.5G cursor "$@" }
