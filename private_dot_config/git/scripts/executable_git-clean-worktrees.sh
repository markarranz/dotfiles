#!/usr/bin/env bash
# git-clean-worktrees: Remove worktrees and branches whose remote is gone.
set -euo pipefail

echo "Fetching and pruning..."
git fetch --prune

gone=$(git branch -v | awk '/\[gone\]/ {gsub(/^[+* ]+/, ""); print $1}' || true)

if [[ -z "$gone" ]]; then
    echo "No stale branches found."
    exit 0
fi

while read -r branch; do
    echo "Processing: $branch"

    # Find and remove associated worktree if one exists
    wt=$(git worktree list | grep "\[$branch\]" | awk '{print $1}' || true)
    if [[ -n "$wt" ]] && [[ "$wt" != "$(git rev-parse --show-toplevel)" ]]; then
        if ! git worktree remove "$wt" 2>/dev/null; then
            echo "  ⚠ WARNING: Worktree $wt has uncommitted changes — force removing."
            git worktree remove --force "$wt"
        fi
    fi

    echo "  Deleting branch: $branch"
    git branch -D "$branch"
done <<< "$gone"

git worktree prune
echo "Done."
