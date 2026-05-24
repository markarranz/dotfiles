#!/usr/bin/env bash
# git-clean-worktrees: Remove worktrees and branches whose remote is gone.
set -euo pipefail

find_worktree_for_branch() {
    local branch=$1
    local target_ref="refs/heads/$branch"
    local path=
    local line=

    while IFS= read -r line; do
        case "$line" in
            worktree\ *)
                path=${line#worktree }
                ;;
            branch\ *)
                if [[ "${line#branch }" == "$target_ref" ]]; then
                    printf '%s\n' "$path"
                    return 0
                fi
                ;;
            "")
                path=
                ;;
        esac
    done < <(git worktree list --porcelain)

    return 1
}

worktree_is_dirty() {
    local wt=$1

    ! git -C "$wt" diff --quiet ||
        ! git -C "$wt" diff --cached --quiet ||
        [[ -n "$(git -C "$wt" ls-files --others --exclude-standard)" ]]
}

usage() {
    cat <<EOF
Usage: git clean-worktrees [--force]

Remove local branches whose upstream has been pruned, along with their clean
worktrees. Dirty worktrees are skipped unless --force is passed.
EOF
}

force=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f | --force)
            force=1
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
    shift
done

echo "Fetching and pruning..."
git fetch --prune
git worktree prune

current_worktree=$(git rev-parse --show-toplevel 2>/dev/null || true)
gone=$(git for-each-ref --format='%(refname:short)%09%(upstream:track)' refs/heads |
    awk -F '\t' '$2 ~ /gone/ { print $1 }' || true)

if [[ -z "$gone" ]]; then
    echo "No stale branches found."
    exit 0
fi

while read -r branch; do
    echo "Processing: $branch"

    # Find and remove associated worktree if one exists
    wt=$(find_worktree_for_branch "$branch" || true)
    if [[ -n "$wt" ]]; then
        if [[ -n "$current_worktree" && "$wt" == "$current_worktree" ]]; then
            echo "  Skipping current worktree: $wt"
            continue
        fi

        if worktree_is_dirty "$wt"; then
            if ((force)); then
                echo "  Force removing dirty worktree: $wt"
                git worktree remove --force "$wt"
            else
                echo "  Skipping dirty worktree: $wt"
                continue
            fi
        else
            echo "  Removing worktree: $wt"
            git worktree remove "$wt"
        fi
    fi

    echo "  Deleting branch: $branch"
    git branch -D "$branch"
done <<< "$gone"

git worktree prune
echo "Done."
