#!/usr/bin/env bash

timeout 10 git fetch &>/dev/null
exit_status=$?
if [ $exit_status -eq 0 ]; then
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	HEADHASH=$(git rev-parse HEAD)
	UPSTREAMHASH=$(git rev-parse ${BRANCH}@{upstream})
	if [ "$HEADHASH" != "$UPSTREAMHASH" ]; then
		printf "\n${yellow} There is a new version, run ./install.sh to get latest version${reset}\n\n"
	fi
else
	printf "\n${bred} Unable to check updates ${reset}\n\n"
fi