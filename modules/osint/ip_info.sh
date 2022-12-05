#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -t IP"
	echo ""
	echo "Search for information related to the IP provided."
	echo ""
	echo "Options:"
	echo "  -t, --target          Target IP"
	echo "  -h, --help            Shows this help message"
	exit 0
fi

# initialize variables for the domain and output folder
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

if [ -n "$WHOISXML_API" ]; then
	curl "https://reverse-ip.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ip=${domain}" 2>/dev/null | jq -r '.result[].name' 2>/dev/null | sed -e "s/$/ ${ip}/" > anew -q ip_${domain}_relations.txt
	curl "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=${WHOISXML_API}&domainName=${domain}&outputFormat=json&da=2&registryRawText=1&registrarRawText=1&ignoreRawTexts=1" 2>/dev/null | jq 2>/dev/null > ip_${domain}_whois.txt
	curl "https://ip-geolocation.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ipAddress=${domain}" 2>/dev/null | jq -r '.ip,.location' 2>/dev/null > ip_${domain}_location.txt
	end_func "Results are saved in $domain/osint/ip_[domain_relations|whois|location].txt" ${FUNCNAME[0]}
else
	printf "\n${yellow} No WHOISXML_API var defined, skipping function ${reset}\n"
	exit 1
fi