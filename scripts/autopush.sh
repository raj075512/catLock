#!/bin/bash
#
# autopush.sh — push any commits that exist locally but not on the remote.
#
# Why this exists: Claude works on this repo inside a sandbox whose network
# policy blocks github.com, so it can commit but never push. This script runs
# on YOUR Mac, where the network is fine, and closes that gap.
#
# It is deliberately conservative:
#   - only pushes the branch you are currently on
#   - never pushes main or dev (open a PR for those)
#   - never force-pushes, never commits, never touches your working tree
#   - does nothing at all if there is no upstream or nothing to push
#
# Run it directly, or install it on a timer — see scripts/README-autopush.md
#
set -euo pipefail

REPO="${1:-$HOME/Documents/goCat}"
cd "$REPO" || exit 0

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
[ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ] && exit 0

# Protected branches: these should only ever change via a reviewed PR.
case "$BRANCH" in
  main|master|dev)
    echo "$(date '+%F %T') skipping protected branch '$BRANCH'"
    exit 0
    ;;
esac

# Don't push a dirty tree's worth of confusion — commits only.
# (Uncommitted changes are fine and are simply left alone.)

git fetch --quiet origin "$BRANCH" 2>/dev/null || true

# How many commits do we have that origin doesn't?
AHEAD="$(git rev-list --count "origin/$BRANCH..$BRANCH" 2>/dev/null || echo 'new')"

if [ "$AHEAD" = "0" ]; then
  exit 0
fi

echo "$(date '+%F %T') pushing $AHEAD commit(s) on '$BRANCH'"
git push origin "$BRANCH"
