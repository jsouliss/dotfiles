#!/bin/bash

set -euo pipefail # Exit on errors, unset variables and failed pipes

# Symlink the stow packages in this repo into $HOME.
# Conflicting real files are moved to ~/.dotfiles-backup/<timestamp>/ first.

DOTFILES_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Packages stowed on every host
COMMON_PACKAGES=(
  zsh
  p10k
  git
  tmux
  nvim
  opencode
  claude
)

# nimbus and DESKTOP-P2MLG2F are headless, so no terminal emulator configs
UBUNTU_PACKAGES=()

# kitty-linux is a bundled Linux kitty build, only useful on a Linux desktop
KALI_PACKAGES=(
  kitty-config
  kitty-linux
)

# ghostty config sets macos-* options
DARWIN_PACKAGES=(
  ghostty
  kitty-config
)

RECOMMENDED_COMMANDS=(stow git zsh tmux nvim)

INSTALL=0
DRY_RUN=0
PACKAGES_SET=0
PACKAGES_ARG=""
FAILED=()
BACKED_UP=0

log() { echo "[+] $*"; }
warn() { echo "[!] $*" >&2; }
die() {
  echo "[-] $*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [--install] [--dry-run] [--packages a,b] [-h]

  --install         Run install/<os>.sh before stowing (ubuntu, kali)
  --dry-run         Print what would happen, change nothing
  --packages a,b    Stow only these packages instead of the OS defaults
  -h, --help        Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --install) INSTALL=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --packages)
      [ $# -ge 2 ] || die "--packages needs a comma separated list"
      PACKAGES_SET=1
      PACKAGES_ARG="$2"
      shift
      ;;
    --packages=*)
      PACKAGES_SET=1
      PACKAGES_ARG="${1#*=}"
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option: $1"
      ;;
  esac
  shift
done

detect_os() {
  local id like
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "darwin"
    return
  fi
  [ -r /etc/os-release ] || {
    echo "unknown"
    return
  }
  id="$(. /etc/os-release && echo "${ID:-}")"
  like="$(. /etc/os-release && echo "${ID_LIKE:-}")"
  case " $id $like " in
    *" kali "*) echo "kali" ;;
    *" ubuntu "*) echo "ubuntu" ;;
    *) echo "${id:-unknown}" ;;
  esac
}

run_install() {
  local script=""
  case "$OS" in
    ubuntu) script="install/ubuntu.sh" ;;
    kali) script="install/kali.sh" ;;
    darwin)
      warn "TODO: no macOS installer yet (see brew/brewfile), skipping --install"
      return
      ;;
    *)
      warn "No installer for OS '$OS', skipping --install"
      return
      ;;
  esac
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would run $script"
    return
  fi
  log "Running $script"
  bash "$DOTFILES_DIR/$script"
}

check_package() {
  case "$1" in
    "" | .* | */* | install | brew | node_modules) die "Not a stow package: '$1'" ;;
  esac
  [ -d "$DOTFILES_DIR/$1" ] || die "Package not found: $DOTFILES_DIR/$1"
}

# True when symlink $1 is relative and resolves inside the repo, so stow
# owns it. Stow treats absolute links as foreign even when they point here.
points_into_repo() {
  local link dir
  link="$(readlink "$1")"
  case "$link" in
    /*) return 1 ;;
    *) link="$(dirname "$1")/$link" ;;
  esac
  dir="$(cd -P "$(dirname "$link")" 2>/dev/null && pwd)" || return 1
  case "$dir/" in
    "$DOTFILES_DIR"/*) return 0 ;;
  esac
  return 1
}

add_conflict() {
  local c
  for c in ${CONFLICTS[@]+"${CONFLICTS[@]}"}; do
    [ "$c" = "$1" ] && return
  done
  CONFLICTS+=("$1")
}

# Fill CONFLICTS with $HOME paths (relative) that block stowing package $1
# and count links still to create in PENDING. Fails on a parent directory
# symlinked outside the repo, which is not safe to move.
find_conflicts() {
  local pkg_dir="$DOTFILES_DIR/$1" src rel rest part parent target done_walk out
  CONFLICTS=()
  PENDING=0
  # Ask stow which paths it links, so its ignore rules apply
  if ! out="$(stow -d "$DOTFILES_DIR" -t "$EMPTY_TARGET" --no-folding "${STOW_IGNORE[@]}" -n -v --stow "$1" 2>&1)"; then
    warn "stow cannot list $1:"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    return 1
  fi
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    src="$pkg_dir/$rel"

    # Walk parent dirs: stop at the first one that is missing, a link or a file
    done_walk=0
    parent="$HOME"
    rest="$rel"
    while [ "${rest#*/}" != "$rest" ]; do
      part="${rest%%/*}"
      rest="${rest#*/}"
      parent="$parent/$part"
      if [ -L "$parent" ]; then
        points_into_repo "$parent" || {
          warn "~/${parent#"$HOME"/} is a symlink stow does not own; move it aside and rerun"
          return 1
        }
        # Repo owned folded dir, stow unfolds it under --no-folding
        PENDING=$((PENDING + 1))
        done_walk=1
        break
      elif [ ! -e "$parent" ]; then
        PENDING=$((PENDING + 1))
        done_walk=1
        break
      elif [ ! -d "$parent" ]; then
        add_conflict "${parent#"$HOME"/}"
        PENDING=$((PENDING + 1))
        done_walk=1
        break
      fi
    done
    [ "$done_walk" -eq 1 ] && continue

    target="$HOME/$rel"
    if [ -L "$target" ]; then
      if points_into_repo "$target"; then
        [ "$target" -ef "$src" ] && continue
        # Stale or other package links into the repo are left for stow to handle
      else
        add_conflict "$rel"
      fi
      PENDING=$((PENDING + 1))
    elif [ -e "$target" ]; then
      add_conflict "$rel"
      PENDING=$((PENDING + 1))
    else
      PENDING=$((PENDING + 1))
    fi
  done < <(printf '%s\n' "$out" | sed -n 's/^LINK: \(.*\) => .*/\1/p')
}

backup_path() {
  local rel="$1" dest="$BACKUP_DIR/$1"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would back up ~/$rel to $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  mv "$HOME/$rel" "$dest"
  BACKED_UP=$((BACKED_UP + 1))
  log "Backed up ~/$rel to $dest"
}

restore_path() {
  mv "$BACKUP_DIR/$1" "$HOME/$1"
  BACKED_UP=$((BACKED_UP - 1))
  log "Restored ~/$1"
}

stow_package() {
  local pkg="$1" c out
  if ! find_conflicts "$pkg"; then
    FAILED+=("$pkg")
    return
  fi
  if [ "${#CONFLICTS[@]}" -eq 0 ] && [ "$PENDING" -eq 0 ]; then
    log "$pkg is already stowed"
    [ "$DRY_RUN" -eq 1 ] || stow "${STOW_OPTS[@]}" --restow "$pkg"
    return
  fi

  for c in ${CONFLICTS[@]+"${CONFLICTS[@]}"}; do
    backup_path "$c"
  done

  if [ "$DRY_RUN" -eq 1 ] && [ "${#CONFLICTS[@]}" -gt 0 ]; then
    log "Would stow $pkg after the backups above"
    return
  fi
  if ! out="$(stow "${STOW_OPTS[@]}" -n -v --restow "$pkg" 2>&1)"; then
    warn "stow reports conflicts for $pkg, skipping it:"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    if [ "$DRY_RUN" -eq 0 ]; then
      for c in ${CONFLICTS[@]+"${CONFLICTS[@]}"}; do
        restore_path "$c"
      done
    fi
    FAILED+=("$pkg")
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would stow $pkg:"
    printf '%s\n' "$out" | sed 's/^/    /'
    return
  fi
  stow "${STOW_OPTS[@]}" --restow "$pkg"
  log "Stowed $pkg"
}

OS="$(detect_os)"
log "Detected OS: $OS"
[ "$DRY_RUN" -eq 1 ] && log "Dry run, nothing will change"

if [ "$PACKAGES_SET" -eq 1 ]; then
  [ -n "$PACKAGES_ARG" ] || die "--packages list is empty"
  IFS=',' read -r -a PACKAGES <<<"$PACKAGES_ARG"
else
  PACKAGES=("${COMMON_PACKAGES[@]}")
  case "$OS" in
    ubuntu) PACKAGES+=(${UBUNTU_PACKAGES[@]+"${UBUNTU_PACKAGES[@]}"}) ;;
    kali) PACKAGES+=("${KALI_PACKAGES[@]}") ;;
    darwin) PACKAGES+=("${DARWIN_PACKAGES[@]}") ;;
    *) warn "Unknown OS '$OS', stowing common packages only" ;;
  esac
fi
[ "${#PACKAGES[@]}" -gt 0 ] || die "No packages to stow"
for pkg in "${PACKAGES[@]}"; do
  check_package "$pkg"
done

[ "$INSTALL" -eq 1 ] && run_install

command -v stow >/dev/null 2>&1 || die "stow not found; install it (apt-get install stow or brew install stow) or rerun with --install"

STOW_IGNORE=(--ignore='\.DS_Store')
STOW_OPTS=(-d "$DOTFILES_DIR" -t "$HOME" --no-folding "${STOW_IGNORE[@]}")
EMPTY_TARGET="$(mktemp -d "${TMPDIR:-/tmp}/bootstrap.XXXXXX")"
trap 'rmdir "$EMPTY_TARGET"' EXIT

for pkg in "${PACKAGES[@]}"; do
  stow_package "$pkg"
done

[ "$BACKED_UP" -gt 0 ] && log "Backups saved in $BACKUP_DIR"

missing=()
for cmd in "${RECOMMENDED_COMMANDS[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
[ "${#missing[@]}" -eq 0 ] || warn "Missing recommended commands: ${missing[*]}"

if [ "${#FAILED[@]}" -gt 0 ]; then
  die "Failed packages: ${FAILED[*]}"
fi
log "Done"
