#!/usr/bin/env bash

set -eo pipefail

if [[ "$RUNNER_DEBUG" == 1 ]]; then
  set -x
fi

SEMANTIC_RELEASE_VERSION="23"
DRY_RUN="false"

usage() {
  echo "Usage: $0 [-c] [-s]"
  exit 1
}

while getopts "cd" arg; do
  case $arg in
  c)
    if [[ "$GITHUB_REF_NAME" == "main" ]]; then
      export TAG_COMPONENTS="true"
    fi
    ;;
  d)
    DRY_RUN="true"
    ;;
  *)
    usage
    ;;
  esac
done

npm install \
  conventional-changelog-conventionalcommits@7 \
  semantic-release-major-tag@0 \
  @semantic-release/commit-analyzer@12 \
  @semantic-release/exec@6 \
  @semantic-release/github@10 \
  @semantic-release/release-notes-generator@13

if [[ "$DRY_RUN" == "false" ]]; then
  unset GITHUB_EVENT_NAME
  npx \
    --package "semantic-release@$SEMANTIC_RELEASE_VERSION" \
    --yes \
    semantic-release \
    --extends "$GITHUB_ACTION_PATH/release.config.js" \
    --repository-url "https://github.com/$GITHUB_REPOSITORY"
else
  unset GITHUB_ACTIONS
  if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
    BRANCH="$GITHUB_HEAD_REF"
  else
    BRANCH="$GITHUB_REF_NAME"
  fi

  npx \
    --package "semantic-release@$SEMANTIC_RELEASE_VERSION" \
    --yes \
    semantic-release \
    --branches "$BRANCH" \
    --dry-run \
    --extends "$GITHUB_ACTION_PATH/release.config.js" \
    --no-ci \
    --repository-url "https://github.com/$GITHUB_REPOSITORY"
fi

if [[ ! -f "VERSION.txt" ]]; then
  touch VERSION.txt
fi

VERSION="$(cat VERSION.txt)"
LAST_VERSION="$(cat LAST_VERSION.txt)"

if [[ -z "$VERSION" && "$GITHUB_REF_NAME" == "main" ]]; then
  echo "version=$LAST_VERSION" >>"$GITHUB_OUTPUT"
else
  echo "version=$VERSION" >>"$GITHUB_OUTPUT"
fi
