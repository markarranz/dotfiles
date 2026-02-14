#!/bin/sh
# Rebuild bat theme cache after chezmoi deploys custom themes
if command -v bat >/dev/null 2>&1; then
  bat cache --build >/dev/null
fi
