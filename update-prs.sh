#!/bin/bash

set -e

BASE=${1:-main}

echo "Updating everything with respect to $BASE"

git switch "$BASE"

for BRANCH in $(git branch --list | grep -v '^\*')
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
