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
	echo "Performs web scraping for subdomain discovery on subdomains file and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -i, --input				Subdomains input file"
	echo "  -o, --output			File to save the results in (default: subs_scrap.txt)"
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
	output="subs_scrap.txt"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in th e current working directory."
	exit 1
fi

mkdir -p .tmp

touch .tmp/scrap_subs.txt

## first web probing


if [ ! "$AXIOM" = true ]; then
	resolvers_update_quick_local
	webs/webprobe.sh -i $input -p $HTTPX_PORTS
	[ -s "webs/webs.txt" ] && cat webs/webs.txt | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
	[ -s ".tmp/probed_tmp_scrap.txt" ] && cat .tmp/probed_tmp_scrap.txt | httpx -tls-grab -tls-probe -csp-probe -H "${HEADER}" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info2.txt 2>>"$LOGFILE" &>/dev/null
	[ -s ".tmp/web_full_info2.txt" ] && cat .tmp/web_full_info2.txt | jq -r 'try ."tls-grab"."dns_names"[],try .csp.domains[],try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | sort -u | httpx -silent | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.t
	if [ "$DEEP" = true ]; then
		[ -s ".tmp/probed_tmp_scrap.txt" ] && gospider -S .tmp/probed_tmp_scrap.txt --js -t $GOSPIDER_THREADS -d 3 --sitemap --robots -w -r > .tmp/gospider.txt
	else
		[ -s ".tmp/probed_tmp_scrap.txt" ] && gospider -S .tmp/probed_tmp_scrap.txt --js -t $GOSPIDER_THREADS -d 2 --sitemap --robots -w -r > .tmp/gospider.txt
	fi
	sed -i '/^.\{2048\}./d' .tmp/gospider.txt
	[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | unfurl -u domains 2>>"$LOGFILE" | grep ".$domain$" | anew -q .tmp/scrap_subs.txt
	[ -s ".tmp/scrap_subs.txt" ] && puredns resolve .tmp/scrap_subs.txt -w $output -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null

else
	resolvers_update_quick_axiom
	webs/webprobe.sh -i $input -p $HTTPX_PORTS
	[ -s "webs/webs.txt" ] && cat webs/webs.txt | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
	[ -s ".tmp/probed_tmp_scrap.txt" ] && axiom-scan .tmp/probed_tmp_scrap.txt -m httpx -tls-grab -tls-probe -csp-probe -H \"${HEADER}\" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info2.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	[ -s ".tmp/web_full_info2.txt" ] && cat .tmp/web_full_info2.txt | jq -r 'try ."tls-grab"."dns_names"[],try .csp.domains[],try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | sort -u | httpx -silent | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
	if [ "$DEEP" = true ]; then
		[ -s ".tmp/probed_tmp_scrap.txt" ] && axiom-scan .tmp/probed_tmp_scrap.txt -m gospider --js -d 3 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	else
		[ -s ".tmp/probed_tmp_scrap.txt" ] && axiom-scan .tmp/probed_tmp_scrap.txt -m gospider --js -d 2 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	NUMFILES=0
	touch .tmp/gospider.txt
	[[ -d .tmp/gospider/ ]] && NUMFILES=$(find .tmp/gospider/ -type f | wc -l)
	[[ $NUMFILES -gt 0 ]] && find .tmp/gospider/ -type f -exec cat {} + | sed '/^.\{2048\}./d' | anew -q .tmp/gospider.txt
	[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | unfurl -u domains 2>>"$LOGFILE" | grep ".$domain$" | anew -q .tmp/scrap_subs.txt
	[ -s ".tmp/scrap_subs.txt" ] && axiom-scan .tmp/scrap_subs.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o $output $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
fi