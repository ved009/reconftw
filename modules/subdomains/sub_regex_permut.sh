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
	echo "Performs subdomains permutations by regex patterns given subdomains and saves the results in the specified file."
	echo ""
	echo "Options:"
	echo "  -i, --input				Input file to resolve"
	echo "  -o, --output			File to save the results in (default: subs_perms.txt)"
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

# check if a domain was provided
if [[ -s "$input" ]]; then
	# display error message if no domain is provided
	echo "Error: File not exists or is empty."
	exit 1
fi

# check if an output folder was provided
if [[ -z "$output" ]]; then
	# use the default output folder if no output folder was provided
	output="subs_perms.txt"
fi

# check if the tools directory exists
if [[   ! -d "$tools" ]]; then
	# display error message if the tools directory does not exist
	echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
	exit 1
fi

mkdir -p .tmp

if [ "$DEEP" = true ] || [ "$(cat $input | wc -l)" -le $DEEP_LIMIT ] ; then
	if [ "$PERMUTATIONS_OPTION" = "gotator" ] ; then
		[ -s "$input" ] && gotator -sub $input -perm $tools/permutations_list.txt $GOTATOR_FLAGS -silent 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1.txt
	else
		[ -s "$input" ] && ripgen -d $input -w $tools/permutations_list.txt 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1.txt
	fi
elif [ "$(cat .tmp/subs_no_resolved.txt | wc -l)" -le $DEEP_LIMIT2 ]; then
	if [ "$PERMUTATIONS_OPTION" = "gotator" ] ; then
		[ -s ".tmp/subs_no_resolved.txt" ] && gotator -sub .tmp/subs_no_resolved.txt -perm $tools/permutations_list.txt $GOTATOR_FLAGS -silent 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1.txt
	else
		[ -s ".tmp/subs_no_resolved.txt" ] && ripgen -d .tmp/subs_no_resolved.txt -w $tools/permutations_list.txt 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1.txt
	fi
else
	end_subfunc "Skipping Permutations: Too Many Subdomains" ${FUNCNAME[0]}
	return 1
fi
if [ ! "$AXIOM" = true ]; then
	resolvers_update_quick_local
	[ -s ".tmp/gotator1.txt" ] && puredns resolve .tmp/gotator1.txt -w .tmp/permute1.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
else
	resolvers_update_quick_axiom
	[ -s ".tmp/gotator1.txt" ] && axiom-scan .tmp/gotator1.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/permute1.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
fi		
if [ "$PERMUTATIONS_OPTION" = "gotator" ] ; then
	[ -s ".tmp/permute1.txt" ] && gotator -sub .tmp/permute1.txt -perm $tools/permutations_list.txt $GOTATOR_FLAGS -silent 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator2.txt
else
	[ -s ".tmp/permute1.txt" ] && ripgen -d .tmp/permute1.txt -w $tools/permutations_list.txt 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator2.txt
fi
if [ ! "$AXIOM" = true ]; then
	[ -s ".tmp/gotator2.txt" ] && puredns resolve .tmp/gotator2.txt -w .tmp/permute2.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
else
	[ -s ".tmp/gotator2.txt" ] && axiom-scan .tmp/gotator2.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/permute2.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
fi
cat .tmp/permute1.txt .tmp/permute2.txt 2>>"$LOGFILE" | anew -q $output