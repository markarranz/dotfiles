# Tuple icon (`:tuple:`)

Status: **MERGED upstream** (PR #428, merge commit `3b03e68`, 2026-06-03). `:tuple:`
is now in `kvndrsslr/sketchybar-app-font` `main`. Local font is a patched build
that matches main; it becomes "official" once a tagged release/Homebrew bump ships.

## What was done
- Added `["Tuple"] = ":tuple:"` to `lib/app_icons.lua` aliases.
- Installed a locally-built `sketchybar-app-font.ttf` that includes the `:tuple:`
  glyph (the official release does not have it yet).
  - Original font backed up to `~/Library/Fonts/sketchybar-app-font.ttf.bak-20260603-100354`.

## The glyph
Derived from Tuple's own monochrome menu-bar logo (`StatusItem/MainLogo/Prod`,
`Group.pdf`, extracted from `/Applications/Tuple.app/Contents/Resources/Assets.car`).
Flattened to: solid front card + back card as an outline frame. 24×24 viewBox,
single filled path (nonzero-winding hole), no background container.

## Upstream contribution — MERGED
- PR (merged): https://github.com/kvndrsslr/sketchybar-app-font/pull/428
- Repo cloned at `~/Code/public/sketchybar-app-font`, based on upstream/main `3454ddd`.
- Fork: `markarranz/sketchybar-app-font`, branch `add-tuple-icon` (remote `fork`).
- 2 files: `svgs/:tuple:.svg`, `mappings/:tuple:`.
- Verified: `node validate.js` passes, `node build.js` succeeds, glyph renders.
- No existing upstream Tuple issue/PR — net-new, nothing to `Closes`.
- Merged to upstream `main` 2026-06-03 (`3b03e68`). Awaiting next tagged release
  for the icon to land in the official font distribution.

## Caveat
A future official font reinstall (e.g. `sketchybar-app-font` Homebrew/release
update) will overwrite the patched ttf and drop `:tuple:` until the PR merges and
ships. The `app_icons.lua` alias is harmless either way (falls back to `:default:`).
