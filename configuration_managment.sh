#!/bin/bash
#build_is_dirty=$(git status --porcelain | wc -l)
# if [ "$build_is_dirty" -ne 0 ]; then
#     echo "Build is dirty: There are uncommitted changes."
#     echo "Please commit or stash your changes before building."
#     exit 1;
# else
repo_name=$(basename "$(dirname "$(dirname "$PWD")")" 2>/dev/null)
commit=$(git log -1 --pretty=format:'%H' 2>/dev/null)
commit_date=$(git log -1 --pretty=format:'%cd' 2>/dev/null)
last_author=$(git log -1 --pretty=format:'%an' 2>/dev/null)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
last_tag=$(git describe --tags --abbrev=0 2>/dev/null)
last_tag_date=$(git log -1 --pretty=format:'%cd' $last_tag 2>/dev/null)
commits_since_last_tag=$(git rev-list $last_tag..HEAD --count 2>/dev/null)
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
echo ""
exit 0;
#fi
