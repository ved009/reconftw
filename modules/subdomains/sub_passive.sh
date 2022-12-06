#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -d domain -o output"
	echo ""
	echo "Runs subdomains discovery by passive techniques for the given domain and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -d, --domain			Domain to find subdomains for"
	echo "  -o, --output			File to save the results in (default: subs_passive.txt)"
	echo "  -h, --help				Shows this help message"
	exit 0
fi

# initialize variables for the domain and output
domain=""
output=""

# process command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-d|--domain)
			domain="$2"
			shift # past argument
			shift # past value
			;;
		-o|--output)
			output="$2"
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

# check if an output folder was provided
if [[ -z "$output" ]]; then
	# use the default output folder if no output folder was provided
	output="subs_passive.txt"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
	exit 1
fi

# check if the GITHUB_TOKENS environment variable is set
if [[ -z "$GITHUB_TOKENS" ]]; then
	# display warning message if the GITHUB_TOKENS environment variable is not set
	echo "Warning: GITHUB_TOKENS environment variable not set. github-subdomains tool will not be used."
fi

mkdir -p .tmp

# run amass and other tools to find subdomains
if [[ ! "$AXIOM" = true ]]; then
  [[ $RUNAMASS == true ]] && amass enum -passive -d "$domain" -config "$AMASS_CONFIG" -timeout "$AMASS_ENUM_TIMEOUT" -json .tmp/amass_json.json > /dev/null 2>&1
  [[ -s .tmp/amass_json.json ]] && cat .tmp/amass_json.json | jq -r '.name' | anew -q .tmp/amass_psub.txt
  [[ $RUNSUBFINDER == true ]] && subfinder -all -d "$domain" -silent | anew -q .tmp/amass_psub.txt
  [[ "$SUBCRT" == true ]] && python3 $tools/ctfr/ctfr.py -d $domain -o .tmp/crtsh_subs_tmp.txt 2>>"$LOGFILE" &>/dev/null
  [[ -s .tmp/crtsh_subs_tmp.txt ]] && cat .tmp/crtsh_subs_tmp.txt | sed 's/\*.//g' | anew .tmp/crtsh_subs.txt | sed '/^$/d' | anew -q .tmp/amass_psub.txt
else
  echo "$domain" > .tmp/amass_temp_axiom.txt
  [[ $RUNAMASS == true ]] && axiom-scan .tmp/amass_temp_axiom.txt -m amass -passive -o .tmp/amass_axiom.txt $AXIOM_EXTRA_ARGS >/dev/null
  [[ $RUNSUBFINDER == true ]] && axiom-scan ".tmp/amass_temp_axiom.txt" -m subfinder -all -silent -o ".tmp/subfinder_axiom.txt" $AXIOM_EXTRA_ARGS > /dev/null 2>&1
  cat ".tmp/amass_axiom.txt" ".tmp/subfinder_axiom.txt" 2>>"$LOGFILE" | anew -q .tmp/amass_psub.txt
fi
if [ -s "${GITHUB_TOKENS}" ]; then
  if [ "$DEEP" = true ]; then
    github-subdomains -d "$domain" -t "$GITHUB_TOKENS" -o ".tmp/github_subdomains_psub.txt" > /dev/null 2>&1
  else
    github-subdomains -d "$domain" -k -q -t "$GITHUB_TOKENS" -o ".tmp/github_subdomains_psub.txt"
	  fi
fi
cat .tmp/github_subdomains_psub.txt .tmp/amass_psub.txt 2>/dev/null | anew -q $output