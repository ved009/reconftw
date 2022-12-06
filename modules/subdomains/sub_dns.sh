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
	echo "Get subdomains from DNS records given subdomains file and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -i, --input				Subdomains input file"
	echo "  -o, --output			File to save the results in (default: subs_dns.txt)"
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

if [[ -s "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: File not exists or is empty."
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
	cat $input | dnsx -r $resolvers_trusted -a -aaaa -cname -ns -ptr -mx -soa -silent -retry 3 -json -o .tmp/subdomains_dnsregs.json > /dev/null 2>&1
	if [ -s ".tmp/subdomains_dnsregs.json" ]; then
		cat .tmp/subdomains_dnsregs.json | jq -r 'try .a[], try .aaaa[], try .cname[], try .ns[], try .ptr[], try .mx[], try .soa[]' 2>/dev/null | anew -q .tmp/subdomains_dns.txt
		cat .tmp/subdomains_dnsregs.json | jq -r 'try .a[]' | sort -u | dnsx -retry 3 -silent -ptr -r $resolvers_trusted -resp-only 2>/dev/null | anew -q .tmp/subdomains_dns.txt
		cat .tmp/subdomains_dnsregs.json | jq -r 'try "\(.host) - \(.a[])"' 2>/dev/null | sort -u -k2 | anew -q .tmp/subdomains_ips.txt
	fi
else
	axiom-scan $input -m dnsx -retry 3 -a -aaaa -cname -ns -ptr -mx -soa -json -o .tmp/subdomains_dnsregs.json $AXIOM_EXTRA_ARGS > /dev/null 2>&1
	if [ -s ".tmp/subdomains_dnsregs.json" ]; then
		cat .tmp/subdomains_dnsregs.json | jq -r 'try .a[]' | sort -u | anew -q .tmp/subdomains_dns_a_records.txt
		[ -s ".tmp/subdomains_dns_a_records.txt" ] && axiom-scan .tmp/subdomains_dns_a_records.txt -m dnsx -retry 3 -ptr -resp-only -o .tmp/subdomains_dns_ptr_reverse.txt $AXIOM_EXTRA_ARGS > /dev/null 2>&1
		[ -s ".tmp/subdomains_dns_ptr_reverse.txt" ] && cat .tmp/subdomains_dns_ptr_reverse.txt | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		cat .tmp/subdomains_dnsregs.json | jq -r 'try .a[], try .aaaa[], try .cname[], try .ns[], try .ptr[], try .mx[], try .soa[]' 2>/dev/null | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		cat .tmp/subdomains_dnsregs.json | jq -r 'try "\(.host) - \(.a[])"' 2>/dev/null | sort -u -k2 | anew -q .tmp/subdomains_ips.txt
	fi

fi
resolvers_update_quick_axiom
[ -s ".tmp/subdomains_dns.txt" ] && puredns resolve .tmp/subdomains_dns.txt -w subs_dns.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT > /dev/null 2>&1