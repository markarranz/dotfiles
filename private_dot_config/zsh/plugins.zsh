plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-autosuggestions"

plug "zap-zsh/supercharge"
plug "zap-zsh/exa"

OMZ_PLUGINS=(
  aliases
  brew
  direnv
  git
)

for p in "${OMZ_PLUGINS[@]}"; do
  plug "$ZDOTDIR/omz/plugins/$p"
done
