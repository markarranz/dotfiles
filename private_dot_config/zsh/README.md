# zsh

## Setup

### Install zap-zsh

```sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

## OMZ Plugin Support

To add oh-my-zsh plugins:

1. add the plugin name to the `OMZ_PLUGINS` array in [`plugins.zsh`](./plugins.zsh)
1. add the plugin name to the `includes` array in [`.chezmoiexternal.toml`](../../.chezmoiexternal.toml.tmpl)
