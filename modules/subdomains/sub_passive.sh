#!/usr/bin/env bash

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -d domain -o output_folder"
	echo ""
	echo "Runs amass and other tools to find subdomains for the given domain and saves the results in the specified folder."
	echo ""
	echo "Options:"
	echo "  -d, --domain          Domain to find subdomains for"
	echo "  -o, --output-folder   Folder to save the results in (default: .tmp)"
	echo "  -h, --help            Shows this help message"
	exit 0
fi

# initialize variables for the domain and output folder
domain=""
output_folder=""

# process command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-d|--domain)
			domain="$2"
			shift # past argument
			shift # past value
			;;
		-o|--output-folder)
			output_folder="$2"
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
if [[ -z "$output_folder" ]]; then
	# use the default output folder if no output folder was provided
	output_folder=".tmp"
	mkdir -p $output_folder
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

# run amass and other tools to find subdomains
if [[ ! "$AXIOM" = true ]]; then
  [[ $RUNAMASS == true ]] && amass enum -passive -d "$domain" -config "$AMASS_CONFIG" -timeout "$AMASS_ENUM_TIMEOUT" -json "$output_folder/amass_json.json" 2>>"$LOGFILE" &>/dev/null
  [ -s "$output_folder/amass_json.json" ] && cat "$output_folder/amass_json.json" | jq -r '.name' | anew -q "$output_folder/amass_psub.txt"
  [[ $RUNSUBFINDER == true ]] && subfinder -all -d "$domain" -silent | anew -q "$output_folder/amass_psub.txt"
else
  echo "$domain" > "$output_folder/amass_temp_axiom.txt"
  [[ $RUNAMASS == true ]] && axiom-scan "$output_folder/amass_temp_axiom.txt" -m amass -passive -o "$output_folder/amass_axiom.txt" $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
  [[ $RUNSUBFINDER == true ]] && axiom-scan "$output_folder/amass_temp_axiom.txt" -m subfinder -all -silent -o "$output_folder/subfinder_axiom.txt" $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
  cat "$output_folder/amass_axiom.txt" "$output_folder/subfinder_axiom.txt" 2>>"$LOGFILE" | anew -q "$output_folder/amass_psub.txt"
fi
if [ -s "${GITHUB_TOKENS}" ]; then
  if [ "$DEEP" = true ]; then
    github-subdomains -d "$domain" -t "$GITHUB_TOKENS" -o "$output_folder/github_subdomains_psub.txt" 2>>"$LOGFILE" &>/dev/null
  else
    github-subdomains -d "$domain" -k -q -t "$GITHUB_TOKENS" -o "$output_folder/github_subdomains_psub.txt"
	  fi
fi
if [ "$INSCOPE" = true ]; then
  check_inscope "$output_folder/amass_psub.txt" 2>>"$LOGFILE" &>/dev/null
  check_inscope "$output_folder/github_subdomains_psub.txt" 2>>"$LOGFILE" &>/dev/null
fi