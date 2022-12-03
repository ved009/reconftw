#!/usr/bin/env bash

if [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Active Subdomain Enumeration"
	find .tmp -type f -iname "*_subs.txt" -exec cat {} + | anew -q .tmp/subs_no_resolved.txt
	deleteOutScoped $outOfScope_file .tmp/subs_no_resolved.txt
	if [ ! "$AXIOM" = true ]; then
		resolvers_update_quick_local
		[ -s ".tmp/subs_no_resolved.txt" ] && puredns resolve .tmp/subs_no_resolved.txt -w .tmp/subdomains_tmp.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT &>/dev/null
	else
		resolvers_update_quick_axiom
		[ -s ".tmp/subs_no_resolved.txt" ] && axiom-scan .tmp/subs_no_resolved.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subdomains_tmp.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	echo $domain | dnsx -retry 3 -silent -r $resolvers_trusted 2>>"$LOGFILE" | anew -q .tmp/subdomains_tmp.txt
	if [ "$DEEP" = true ]; then
		cat .tmp/subdomains_tmp.txt | tlsx -san -cn -silent -ro -c $TLSX_THREADS -p $TLS_PORTS | anew -q .tmp/subdomains_tmp.txt
	else
		cat .tmp/subdomains_tmp.txt | tlsx -san -cn -silent -ro -c $TLSX_THREADS | anew -q .tmp/subdomains_tmp.txt
	fi
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/subdomains_tmp.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/subdomains_tmp.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | anew subdomains/subdomains.txt | sed '/^$/d' | wc -l)
	end_subfunc "${NUMOFLINES} subs DNS resolved from passive" ${FUNCNAME[0]}
else
	printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
fi