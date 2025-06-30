#!/usr/bin/env bash

set -eo pipefail

if [[ "$RUNNER_DEBUG" == 1 ]]; then
  set -x
  echo "::debug::RUNNER_DEBUG is set to 1, enabling debug mode"
fi

SEMANTIC_RELEASE_VERSION="23"
echo "::debug::Using semantic-release version $SEMANTIC_RELEASE_VERSION"
DRY_RUN="false"

usage() {
  echo "Usage: $0 [-c] [-s]"
  exit 1
}

while getopts "cd" arg; do
  case $arg in
  c)
    echo "::debug::[-c] flag was set"
    if [[ "$GITHUB_REF_NAME" == "main" ]]; then
      echo "::debug:: ==> GITHUB_REF_NAME is main, setting TAG_COMPONENTS to true"
      export TAG_COMPONENTS="true"
    fi
    ;;
  d)
    echo "::debug::[-d] flag was set"
    DRY_RUN="true"
    ;;
  *)
    usage
    ;;
  esac
done

echo "::debug::Installing dependencies for semantic-release"
npm install \
  conventional-changelog-conventionalcommits@7 \
  semantic-release-major-tag@0 \
  @semantic-release/commit-analyzer@12 \
  @semantic-release/exec@6 \
  @semantic-release/github@10 \
  @semantic-release/release-notes-generator@13

if [[ "$DRY_RUN" == "false" ]]; then
  echo "::debug::Running semantic-release in production mode"
  unset GITHUB_EVENT_NAME
  npx \
    --package "semantic-release@$SEMANTIC_RELEASE_VERSION" \
    --yes \
    semantic-release \
    --extends "$GITHUB_ACTION_PATH/release.config.js" \
    --repository-url "https://github.com/$GITHUB_REPOSITORY"
  echo "::debug::semantic-release completed successfully"
else
  echo "::debug::Running semantic-release in dry-run mode"
  unset GITHUB_ACTIONS
  if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
    echo "::debug::GITHUB_EVENT_NAME is pull_request, using GITHUB_HEAD_REF for branch"
    BRANCH="$GITHUB_HEAD_REF"
  else
    echo "::debug::GITHUB_EVENT_NAME is not pull_request, using GITHUB_REF_NAME for branch"
    BRANCH="$GITHUB_REF_NAME"
  fi

  echo "::debug::Using branch: $BRANCH"
  npx \
    --package "semantic-release@$SEMANTIC_RELEASE_VERSION" \
    --yes \
    semantic-release \
    --branches "$BRANCH" \
    --dry-run \
    --extends "$GITHUB_ACTION_PATH/release.config.js" \
    --no-ci \
    --repository-url "https://github.com/$GITHUB_REPOSITORY"
  echo "::debug::semantic-release dry-run completed successfully"
fi

if [[ ! -f "VERSION.txt" ]]; then
  echo "::debug::VERSION.txt does not exist, creating it"
  touch VERSION.txt
fi

VERSION="$(cat VERSION.txt)"
echo "::debug::Read version from VERSION.txt: $VERSION"
LAST_VERSION="$(cat LAST_VERSION.txt)"
echo "::debug::Read last version from LAST_VERSION.txt: $LAST_VERSION"

if [[ -z "$VERSION" && "$GITHUB_REF_NAME" == "main" ]]; then
  echo "::debug::VERSION is empty and GITHUB_REF_NAME is main, using LAST_VERSION"
  echo "version=$LAST_VERSION" >>"$GITHUB_OUTPUT"
else
  echo "::debug::VERSION is not empty or GITHUB_REF_NAME is not main, using VERSION"
  echo "version=$VERSION" >>"$GITHUB_OUTPUT"
fi
