#!/usr/bin/env bash
#
# install.sh — Install all tools and prerequisites for these dotfiles.
#
# Supports macOS (Homebrew) and Arch Linux (pacman + yay).
#
# Usage:
#   ./install.sh          Install everything for the current platform
#   ./install.sh --help   Show this help message
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info() { printf "${BLUE}::${RESET} %s\n" "$*"; }
success() { printf "${GREEN}::${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}:: %s${RESET}\n" "$*"; }
error() { printf "${RED}:: %s${RESET}\n" "$*" >&2; }

confirm() {
  printf "${BOLD}%s [Y/n]${RESET} " "$1"
  read -r answer
  case "$answer" in
  [nN]*) return 1 ;;
  *) return 0 ;;
  esac
}

command_exists() { command -v "$1" &>/dev/null; }

# ---------------------------------------------------------------------------
# Detect platform
# ---------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
Darwin) PLATFORM="macos" ;;
Linux) PLATFORM="linux" ;;
*)
  error "Unsupported platform: $OS"
  exit 1
  ;;
esac

if [[ "$PLATFORM" == "linux" ]] && ! command_exists pacman; then
  error "This script expects Arch Linux (pacman not found)."
  error "For other distributions, install the equivalent packages manually."
  exit 1
fi

info "Detected platform: $PLATFORM"

# ---------------------------------------------------------------------------
# Package lists
# ---------------------------------------------------------------------------

# Cross-platform tools (installed on both macOS and Linux)
COMMON_TOOLS=(
  bat
  btop
  chezmoi
  direnv
  eza
  fzf
  git
  git-delta
  jq
  neovim
  ripgrep
  starship
  tmux
  yazi
  zoxide
  zsh
)

# --- macOS (Homebrew) ---
BREW_FORMULAE=(
  "${COMMON_TOOLS[@]}"
  nvm
  switchaudio-osx
  terminal-notifier
)

BREW_CASKS=(
  blackhole-2ch
  font-jetbrains-mono-nerd-font
  font-noto-color-emoji
  font-sketchybar-app-font
  karabiner-elements
  kitty
)

BREW_TAPS=(
  jackielii/tap
  koekeishiya/formulae
  FelixKratz/formulae
)

BREW_TAP_FORMULAE=(
  koekeishiya/formulae/yabai
  jackielii/tap/skhd-zig
  FelixKratz/formulae/sketchybar
  FelixKratz/formulae/borders
)

# --- Arch Linux (pacman) ---
PACMAN_PACKAGES=(
  "${COMMON_TOOLS[@]}"
  kitty
  noto-fonts-emoji
  nvm
  ttf-jetbrains-mono-nerd
  firefox
  # Hyprland ecosystem
  hyprland
  hyprlock
  hypridle
  hyprpaper
  hyprsunset
  uwsm
  # Desktop utilities
  blueman
  brightnessctl
  nautilus
  nm-connection-editor
  playerctl
  qt6ct
  rofi
  rofi-calc
  # PDF viewer
  zathura
  zathura-pdf-mupdf
)

AUR_PACKAGES=(
  ashell
  kanata
  pwvucontrol
  walker
)

# ---------------------------------------------------------------------------
# macOS installation
# ---------------------------------------------------------------------------
install_macos() {
  info "Starting macOS installation..."

  # Homebrew
  if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for the rest of this script
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    success "Homebrew already installed"
  fi

  # Taps
  info "Adding Homebrew taps..."
  for tap in "${BREW_TAPS[@]}"; do
    brew tap "$tap" 2>/dev/null || true
  done

  # Formulae
  info "Installing Homebrew formulae..."
  brew install "${BREW_FORMULAE[@]}" || true

  # Tap formulae (from custom taps)
  info "Installing tools from custom taps..."
  brew install "${BREW_TAP_FORMULAE[@]}" || true

  # Casks
  info "Installing Homebrew casks..."
  brew install --cask "${BREW_CASKS[@]}" || true

  # Zathura (requires its own tap)
  info "Installing Zathura..."
  brew tap homebrew-zathura/zathura 2>/dev/null || true
  brew install zathura zathura-pdf-mupdf 2>/dev/null || true

  # SBarLua (SketchyBar Lua API)
  if [[ ! -d "$HOME/.local/share/sketchybar_lua" ]]; then
    info "Installing SBarLua..."
    git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua &&
      (cd /tmp/SbarLua && make install) &&
      rm -rf /tmp/SbarLua
    success "SBarLua installed"
  else
    success "SBarLua already installed"
  fi

  success "macOS packages installed"
}

# ---------------------------------------------------------------------------
# Arch Linux installation
# ---------------------------------------------------------------------------
install_linux() {
  info "Starting Arch Linux installation..."

  # Sync package databases
  info "Updating package databases..."
  sudo pacman -Sy --noconfirm

  # Official repo packages
  info "Installing pacman packages..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

  # AUR helper
  if ! command_exists yay; then
    info "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    success "yay installed"
  else
    success "yay already installed"
  fi

  # AUR packages
  info "Installing AUR packages..."
  yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

  # Enable Kanata systemd service
  if command_exists kanata; then
    info "Enabling Kanata keyboard remapper service..."
    systemctl --user enable kanata.service 2>/dev/null || true
  fi

  success "Arch Linux packages installed"
}

# ---------------------------------------------------------------------------
# Cross-platform post-install setup
# ---------------------------------------------------------------------------
setup_common() {
  info "Running post-install setup..."

  # TPM (Tmux Plugin Manager)
  local tpm_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    success "TPM installed — press prefix + I inside tmux to install plugins"
  else
    success "TPM already installed"
  fi

  # Claude Code
  if ! command_exists claude; then
    if confirm "Install Claude Code CLI?"; then
      curl -fsSL https://claude.ai/install.sh | bash
      success "Claude Code installed"
    else
      warn "Skipping Claude Code"
    fi
  else
    success "Claude Code already installed"
  fi

  # chezmoi init
  if confirm "Apply dotfiles with chezmoi now?"; then
    if [[ -d "$HOME/.local/share/chezmoi" ]]; then
      info "Applying chezmoi..."
      chezmoi apply
    else
      info "Initializing chezmoi from this directory..."
      chezmoi init --apply --source "$(cd "$(dirname "$0")" && pwd)"
    fi
    success "Dotfiles applied"
  else
    warn "Skipping chezmoi apply — run 'chezmoi apply' when ready"
  fi

  # Set default shell to Zsh
  local current_shell
  current_shell="$(basename "$SHELL")"
  if [[ "$current_shell" != "zsh" ]]; then
    if confirm "Change default shell to Zsh?"; then
      chsh -s "$(which zsh)"
      success "Default shell changed to Zsh (takes effect on next login)"
    fi
  else
    success "Default shell is already Zsh"
  fi
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_summary() {
  echo ""
  printf '%s%sInstallation complete!%s\n' "$GREEN" "$BOLD" "$RESET"
  echo ""
  echo "Next steps:"
  echo "  1. Open a new terminal (or restart your shell)"
  echo "  2. Inside tmux, press Ctrl+Space then I to install tmux plugins"
  echo "  3. Open Neovim — LazyVim will install plugins on first launch"
  if [[ "$PLATFORM" == "macos" ]]; then
    echo "  4. Start your window manager: yabai + skhd"
    echo "  5. Start SketchyBar: brew services start sketchybar"
  else
    echo "  4. Log out and back in to start Hyprland via uwsm"
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    head -11 "$0" | tail -8 | sed 's/^# *//'
    exit 0
  fi

  echo ""
  printf '%sDotfiles Installer%s\n' "$BOLD" "$RESET"
  echo "This will install all tools and prerequisites."
  echo ""

  if ! confirm "Continue?"; then
    info "Aborted."
    exit 0
  fi

  echo ""

  case "$PLATFORM" in
  macos) install_macos ;;
  linux) install_linux ;;
  esac

  setup_common
  print_summary
}

main "$@"
