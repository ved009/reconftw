#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -i input -p ports -o output"
	echo ""
	echo "Performs web probing on multiple ports for web discovery on subdomains file and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -i, --input				Subdomains input file"
	echo "  -p, --ports				Ports list to scan (default: 80,443)"
	echo "  -o, --output			File to save the results in (default: web_info.txt)"
	echo "  -h, --help				Shows this help message"
	exit 0
fi

# initialize variables for the domain and output
input=""
output=""
ports=""

# process command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-i|--input)
			input="$2"
			shift # past argument
			shift # past value
			;;
		-o|--output)
			output="$2"
			shift # past argument
			shift # past value
			;;
		-p|--ports)
			ports="$2"
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
if [[ -z "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: No file provided. Use ${name} -h for usage information."
	exit 1
fi

if [[ -s "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: File not exists or is empty."
	exit 1
fi

# check if an output folder was provided
if [[ -z "$output" ]]; then
	# use the default output folder if no output folder was provided
	output="web_info.txt"
fi

# check if a domain was provided
if [[ -z "$ports" ]]; then
	# display error message if no domain is provided
	ports="80,443"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in th e current working directory."
	exit 1
fi

if [ ! "$AXIOM" = true ]; then
	if [ -s "subdomains/subdomains.txt" ]; then
		cat subdomains/subdomains.txt | httpx -p $ports -threads $HTTPX_THREADS -timeout $HTTPX_TIMEOUT -silent -retries 2 -random-agent -status-code -title -web-server -tech-detect -location -follow-host-redirects -json -no-color -o $output 2>>"$LOGFILE" &>/dev/null
	fi
else
	if [ -s "subdomains/subdomains.txt" ]; then
		axiom-scan subdomains/subdomains.txt -m httpx -p $UNCOMMON_PORTS_WEB -threads $HTTPX_THREADS -timeout $HTTPX_TIMEOUT -silent -retries 2 -random-agent -status-code -title -web-server -tech-detect -location -follow-host-redirects -json -no-color -o $output $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
fi