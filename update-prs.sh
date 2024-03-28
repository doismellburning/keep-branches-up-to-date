#!/bin/bash

set -e


function configure_git {

	if ! git config user.email
	then
		git config --local user.email "github-pr-branch-updater@example.invalid"
	fi

	if ! git config user.name
	then
		git config --local user.name "GitHub PR Branch Updater Workflow"
	fi
}


configure_git

BASE=${1:-main}

echo "Updating everything with respect to $BASE"

git switch "$BASE"

BRANCHES=$(gh pr list --json "headRefName" --jq '.[].headRefName')

echo "Processing $BRANCHES"

for BRANCH in $BRANCHES
do
	echo "Processing branch $BRANCH"
	git switch "$BRANCH"

	if git rebase "$BASE"
	then
		git push --force-with-lease
	else
		echo "Failed to automagically rebase $BRANCH, aborting and continuing"
		git rebase --abort
	fi
done

echo "Returning to $BASE"

git switch "$BASE"
