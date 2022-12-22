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
	echo "Performs subdomains DNS bruteforcing given a target domain and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -d, --domain			Target domain"
	echo "  -o, --output			File to save the results in (default: subs_brute.txt)"
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
			input="$2"
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
	echo "Error: No input provided. Use ${name} -h for usage information."
	exit 1
fi

# check if an output folder was provided
if [[ -z "$output" ]]; then
	# use the default output folder if no output folder was provided
	output="subs_dns.txt"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in th e current working directory."
	exit 1
fi

mkdir -p .tmp

if [ ! "$AXIOM" = true ]; then
	resolvers_update_quick_local
	if [ "$DEEP" = true ]; then
		puredns bruteforce $subs_wordlist_big $domain -w .tmp/subs_brute.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT > /dev/null 2>&1
	else
		puredns bruteforce $subs_wordlist $domain -w .tmp/subs_brute.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT > /dev/null 2>&1
	fi
	[ -s ".tmp/subs_brute.txt" ] && puredns resolve .tmp/subs_brute.txt -w subs_brute.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT > /dev/null 2>&1
else
	resolvers_update_quick_axiom
	if [ "$DEEP" = true ]; then
		axiom-scan $subs_wordlist_big -m puredns-single $domain -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subs_brute.txt $AXIOM_EXTRA_ARGS > /dev/null 2>&1
	else
		axiom-scan $subs_wordlist -m puredns-single $domain -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subs_brute.txt $AXIOM_EXTRA_ARGS > /dev/null 2>&1
	fi
	[ -s ".tmp/subs_brute.txt" ] && axiom-scan .tmp/subs_brute.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o subs_brute.txt $AXIOM_EXTRA_ARGS > /dev/null 2>&1
fi