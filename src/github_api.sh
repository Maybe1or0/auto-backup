#!/usr/bin/env bash

get_repos() {
  if [ -z "${GITHUB_USERNAME:-}" ]; then
    printf '%s\n' "GITHUB_USERNAME is not set" >&2
    return 1
  fi

  GH_PAGER=cat gh repo list "$GITHUB_USERNAME" --limit 1000 --json name --jq '.[].name'
}
