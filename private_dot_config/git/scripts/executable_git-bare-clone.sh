#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-l] repository [directory]

Clone a bare git repo and set up environment for working comfortably and exclusively from worktrees.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-l, --location  Location of the bare repo contents (default: .bare)
EOF
  exit
}

repo_name_from_url() {
  local url="$1"
  url="${url%%/}"
  url="${url%.git}"
  echo "${url##*/}"
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  location='.bare'

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -l | --location)
      location="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  [[ ${#args[@]} -eq 0 ]] && die "Missing repository argument"

  repository="${args[0]}"
  directory="${args[1]:-$(repo_name_from_url "$repository")}"

  return 0
}

parse_params "$@"
setup_colors

[[ -e "$directory" ]] && die "${RED}fatal: destination path '$directory' already exists.${NOFORMAT}"

msg "${YELLOW}Creating $directory...${NOFORMAT}"
mkdir -p "$directory"
cd "$directory"

msg "${YELLOW}Cloning bare repository to $location...${NOFORMAT}"
git clone --bare "$repository" "$location"

msg "${YELLOW}Adjusting origin fetch locations...${NOFORMAT}"
git -C "$location" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

msg "${YELLOW}Setting .git file contents...${NOFORMAT}"
echo "gitdir: ./$location" >.git
msg "${GREEN}Cloned into '$directory'.${NOFORMAT}"
