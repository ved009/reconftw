#!/usr/bin/env bash

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
  # display improved help information
  echo "Usage: ${name} -d domain -t tokens_file -g gitdorks_file"
  echo ""
  echo "Runs gitdorks_go for the given domain."
  echo ""
  echo "Options:"
  echo "  -d, --domain			Domain to run dorks_hunter for"
  echo "  -t, --tokens			File containing GitHub tokens"
  echo "  -g, --gitdorks		File containing GitHub dorks"
  echo "  -h, --help			Shows this help message"
  exit 0
fi

# initialize variables for the domain and output folder
domain=""
tokens=""
gitdorks=""

# process command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--domain)
      domain="$2"
      shift # past argument
      shift # past value
      ;;
	-t|--tokens)
      tokens="$2"
      shift # past argument
      shift # past value
      ;;
    -g|--output-folder)
      gitdorks="$3"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      echo "Error: Invalid option: $key"
      exit 1
      ;;
  esac
done

# check if arg was provided
if [[ -z "$domain" ]]; then
  # display error message if no arg is provided
  echo "Error: No arg provided. Use ${name} -h for usage information."
  exit 1
fi

# check if arg was provided
if [[ -z "$tokens" ]]; then
  # display error message if no arg is provided
  echo "Error: No domain provided. Use ${name} -h for usage information."
  exit 1
fi

# check if an output folder was provided
if [[ -z "$gitdorks" ]]; then
  # display error message if no arg is provided
  echo "Error: No domain provided. Use ${name} -h for usage information."
  exit 1
fi

# run the tool for the given args
gitdorks_go -gd $gitdorks -nws 20 -target $domain -tf $tokens -ew 3
