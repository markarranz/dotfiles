# zsh

Add the following to the `/etc/zshenv` file:

```sh
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
```

## OMZ Plugin Support

To add oh-my-zsh plugins:

1. add the plugin name to the `OMZ_PLUGINS` array in [`plugins.zsh`](./plugins.zsh)
1. add the plugin name to the `includes` array in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl)
