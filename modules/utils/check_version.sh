#!/usr/bin/env bash

# check if the 'git' command is available
if ! command -v git &>/dev/null; then
  # display error message if 'git' is not available
  printf "\n${bred} Error: 'git' is not available. Make sure it is installed and available in the current PATH.${reset}\n\n"
  exit 1
fi

# run 'git fetch' with a timeout of 10 seconds
timeout 10 git fetch &>/dev/null
exit_status=$?

# check if 'git fetch' was successful
if [ $exit_status -eq 0 ]; then
  # get the current branch and the hashes of the HEAD and upstream commits
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  HEADHASH=$(git rev-parse HEAD)
  UPSTREAMHASH=$(git rev-parse ${BRANCH}@{upstream})

  # check if there is a new version available
  if [ "$HEADHASH" != "$UPSTREAMHASH" ]; then
    # display a message to inform the user that there is a new version available
    printf "\n${yellow} There is a new version available. Run './install.sh' to get the latest version.${reset}\n\n"
  else
    # display a message to inform the user that they are already using the latest version
    printf "\n${green} You are already using the latest version.${reset}\n\n"
  fi
else
  # display an error message if 'git fetch' failed
  printf "\n${bred} Error: Unable to check for updates.${reset}\n\n"
fi