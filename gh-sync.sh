#!/bin/bash

# gh auth login -s workflow,gist

# GitHub username
USERNAME="tektite-io"

# Get a list of all repositories for the user
REPOS=$(gh repo list $USERNAME --fork -L 100 --json name,nameWithOwner,isFork,parent)

# Iterate through each repository
echo $REPOS | jq -c '.[]' | while read repo; do
  REPO_NAME=$(echo $repo | jq -r '.name')
  IS_FORK=$(echo $repo | jq -r '.isFork')
  REPO_NAME_WITH_OWNER=$(echo $repo | jq -r '.nameWithOwner')

  if [ "$IS_FORK" == "true" ]; then
    # Get the parent repository
    PARENT_OWNER=$(echo $repo | jq -r '.parent.owner.login')
    PARENT_NAME=$(echo $repo | jq -r '.parent.name')
    PARENT_REPO="$PARENT_OWNER/$PARENT_NAME"

    echo "Syncing forked repository: $REPO_NAME_WITH_OWNER with upstream: $PARENT_REPO"

    # Fetch and merge upstream changes
    gh repo sync "$REPO_NAME_WITH_OWNER" --source "$PARENT_REPO"
  fi
done
