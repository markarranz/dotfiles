#!/usr/bin/env bash
# git-clean-worktrees: Remove worktrees and branches whose remote is gone.
set -euo pipefail

# git exports GIT_DIR to "!" aliases, which would override `git -C` discovery
unset GIT_DIR GIT_WORK_TREE

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

worktree_is_locked() {
    local wt=$1
    local path=
    local line=

    while IFS= read -r line; do
        case "$line" in
            worktree\ *)
                path=${line#worktree }
                ;;
            locked*)
                if [[ "$path" == "$wt" ]]; then
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

fetch_and_prune() {
    echo "Fetching and pruning..."
    git fetch --all --tags --prune --jobs=10
    git worktree prune
}

cleanup_current_merged_pr() {
    local current_worktree
    local branch
    local common_git_dir
    local remove_args=()
    local state
    local pr_branch
    local pr_url

    current_worktree=$(git rev-parse --show-toplevel)
    branch=$(git symbolic-ref --quiet --short HEAD) || {
        echo "Current worktree is detached; refusing to remove it." >&2
        exit 1
    }
    common_git_dir=$(git rev-parse --path-format=absolute --git-common-dir)

    if worktree_is_locked "$current_worktree"; then
        echo "Current worktree is locked; refusing to remove it: $current_worktree" >&2
        exit 1
    fi

    if worktree_is_dirty "$current_worktree"; then
        if ((force)); then
            remove_args+=(--force)
        else
            echo "Current worktree is dirty; pass --force to remove it anyway: $current_worktree" >&2
            exit 1
        fi
    fi

    fetch_and_prune

    state=$(gh pr view --json state --jq .state 2>/dev/null) || {
        echo "No GitHub PR associated with current branch; refusing to remove $branch." >&2
        exit 1
    }
    pr_branch=$(gh pr view --json headRefName --jq .headRefName)
    pr_url=$(gh pr view --json url --jq .url)

    if [[ "$state" != "MERGED" ]]; then
        echo "PR is $state, not MERGED; refusing to remove $branch." >&2
        echo "PR: $pr_url" >&2
        exit 1
    fi

    if [[ "$pr_branch" != "$branch" ]]; then
        echo "PR head branch is $pr_branch, but current branch is $branch; refusing to remove." >&2
        echo "PR: $pr_url" >&2
        exit 1
    fi

    echo "Removing merged PR worktree: $current_worktree"
    git --git-dir="$common_git_dir" worktree remove "${remove_args[@]}" "$current_worktree"

    echo "Deleting branch: $branch"
    git --git-dir="$common_git_dir" branch -D "$branch"

    git --git-dir="$common_git_dir" worktree prune
    echo "Done."
}

usage() {
    cat <<EOF
Usage: git clean-worktrees [-f|--force] [--current-merged-pr]

Remove local branches whose upstream has been pruned, along with their clean
worktrees. Dirty worktrees are skipped unless --force is passed.

With --current-merged-pr, remove the current clean, unlocked worktree and its
branch after verifying its associated GitHub PR is merged.
EOF
}

force=0
current_merged_pr=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f | --force)
            force=1
            ;;
        --current-merged-pr)
            current_merged_pr=1
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

if ((current_merged_pr)); then
    cleanup_current_merged_pr
    exit 0
fi

fetch_and_prune

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
