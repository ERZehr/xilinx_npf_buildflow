#!/bin/sh
build_is_dirty=$(git status --porcelain | wc -l)
if [ "$build_is_dirty" -ne 0 ]; then
    echo "Build is dirty: There are uncommitted changes."
    echo "Please commit or stash your changes before building."
    exit 1;
else
    repo_name=$(basename $(git rev-parse --show-toplevel))
    commit=$(git log -1 --pretty=format:'%H')
    commit_date=$(git log -1 --pretty=format:'%cd')
    last_author=$(git log -1 --pretty=format:'%an')
    branch=$(git rev-parse --abbrev-ref HEAD)
    last_tag=$(git describe --tags --abbrev=0)
    last_tag_date=$(git log -1 --pretty=format:'%cd' $last_tag)
    commits_since_last_tag=$(git rev-list $last_tag..HEAD --count)
    current_date=$(date +"%Y-%m-%d %H:%M:%S")

    echo "Building Repository: $repo_name"
    echo "Build Date: $current_date"
    echo "Build Commit: $commit"
    echo "Commit Date: $commit_date"
    echo "Commit Author: $last_author"
    echo "Build Branch: $branch"
    echo "Last Tag: $last_tag"
    echo "Last Tag Date: $last_tag_date"
    echo "Commits Since Last Tag: $commits_since_last_tag"
    exit 0;
fi
