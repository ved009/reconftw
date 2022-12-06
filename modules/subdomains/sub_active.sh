#!/usr/bin/env bash

# Loads reconftw vars
source $HOME/.reconftw/reconftw.cfg	

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
	# display improved help information
	echo "Usage: ${name} -i input -o output"
	echo ""
	echo "Runs subdomains resolution given file and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -i, --input				Input file to resolve"
	echo "  -o, --output			File to save the results in (default: subs_active.txt)"
	echo "  -h, --help				Shows this help message"
	exit 0
fi

# initialize variables for the domain and output
input=""
output=""

# process command line arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-i|--input)
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
if [[ -z "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: No file provided. Use ${name} -h for usage information."
	exit 1
fi

# check if a domain was provided
if [[ -s "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: File not exists or is empty."
	exit 1
fi

# check if an output folder was provided
if [[ -z "$output" ]]; then
	# use the default output folder if no output folder was provided
	output="subs_active.txt"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
	exit 1
fi

mkdir -p .tmp

if [ ! "$AXIOM" = true ]; then
	resolvers_update_quick_local
	puredns resolve $input -w $output -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT &>/dev/null
else
	resolvers_update_quick_axiom
	axiom-scan $input -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o $output $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
fi
echo $domain | dnsx -retry 3 -silent -r $resolvers_trusted 2>>"$LOGFILE" | anew -q $output
if [ "$DEEP" = true ]; then
	cat .tmp/subdomains_tmp.txt | tlsx -san -cn -silent -ro -c $TLSX_THREADS -p $TLS_PORTS | anew -q $output
else
	cat .tmp/subdomains_tmp.txt | tlsx -san -cn -silent -ro -c $TLSX_THREADS | anew -q $output
fi