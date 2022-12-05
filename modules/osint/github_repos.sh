#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -d domain -t tokens_file -o output"
	echo ""
	echo "Searches for secrets in target's repositories for the given domain."
	echo ""
	echo "Options:"
	echo "  -d, --domain			Target domain"
	echo "  -t, --tokens			File containing GitHub tokens"
	echo "  -o, --output		File to save the output in (default: github_company_secrets.json)"
	echo "  -h, --help			Shows this help message"
	exit 0
fi

# initialize variables for the domain and output folder
domain=""
tokens=""

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
	 -o|--output-file)
			output_file="$2"
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
	echo "Error: No arg provided. Use ${name} -h for usage information."
	exit 1
fi

# check if an output file was provided
if [[ -z "$output_file" ]]; then
	# use the default output file if no output folder was provided
	output_file="github_company_secrets.json"
fi

# run the tool for the given args
mkdir -p .tmp
GH_TOKEN=$(cat ${GITHUB_TOKENS} | head -1)
echo $domain | unfurl format %r > .tmp/company_name.txt
enumerepo -token-string ${GH_TOKEN} -usernames .tmp/company_name.txt -o .tmp/company_repos.txt 2>>"$LOGFILE" &>/dev/null
[ -s .tmp/company_repos.txt ] && cat .tmp/company_repos.txt | jq -r '.[].repos[]|.url' > .tmp/company_repos_url.txt 2>>"$LOGFILE" &>/dev/null
rush -i .tmp/company_repos_url.txt -j ${INTERLACE_THREADS} "trufflehog git {} -j | jq -c >> github_company_secrets.json" 2>>"$LOGFILE" &>/dev/null