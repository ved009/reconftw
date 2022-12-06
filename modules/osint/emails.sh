#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -d domain"
	echo ""
	echo "Searches emails, employees names and linkedin profiles for the given domain"
	echo ""
	echo "Options:"
	echo "  -d, --domain          Target domain"
	echo "  -h, --help            Shows this help message"
	exit 0
fi

# initialize variables for the domain
domain=""

# process command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-d|--domain)
			domain="$2"
			shift # past argument
			shift # past value
			;;
		*)    # unknown option
			echo "Error: Invalid option: $key"
			exit 1
			;;
	esac
done

# check if a domain was provided
if [[ -z "$domain" ]]; then
	# display error message if no domain is provided
	echo "Error: No domain provided. Use ${name} -h for usage information."
	exit 1
fi

# check if the tools directory exists
if [[ ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
	exit 1
fi

mkdir -p .tmp

# run the tool for the given args
emailfinder -d $domain 2>/dev/null > .tmp/emailfinder.txt
[ -s ".tmp/emailfinder.txt" ] && cat .tmp/emailfinder.txt | grep "@" | grep -iv "|_" > emails.txt

pushd "$tools/theHarvester" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
python3 theHarvester.py -d $domain -b all -f .tmp/harvester.json > /dev/null 2>&1
popd || { echo "Failed to cd to the original directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }

if [ -s ".tmp/harvester.json" ]; then
	cat .tmp/harvester.json | jq -r 'try .emails[]' 2>/dev/null | anew -q emails.txt
	cat .tmp/harvester.json | jq -r 'try .linkedin_people[]' 2>/dev/null > employees.txt
	cat .tmp/harvester.json | jq -r 'try .linkedin_links[]' 2>/dev/null > linkedin.txt
fi