#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBBRUTE" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Bruteforce Subdomain Enumeration"
	if [ ! "$AXIOM" = true ]; then
		resolvers_update_quick_local
		if [ "$DEEP" = true ]; then
			puredns bruteforce $subs_wordlist_big $domain -w .tmp/subs_brute.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
		else
			puredns bruteforce $subs_wordlist $domain -w .tmp/subs_brute.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
		fi
		[ -s ".tmp/subs_brute.txt" ] && puredns resolve .tmp/subs_brute.txt -w .tmp/subs_brute_valid.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
	else
		resolvers_update_quick_axiom
		if [ "$DEEP" = true ]; then
			axiom-scan $subs_wordlist_big -m puredns-single $domain -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subs_brute.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		else
			axiom-scan $subs_wordlist -m puredns-single $domain -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subs_brute.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		[ -s ".tmp/subs_brute.txt" ] && axiom-scan .tmp/subs_brute.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subs_brute_valid.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/subs_brute_valid.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/subs_brute_valid.txt 2>>"$LOGFILE" | sed "s/*.//" | grep ".$domain$" | anew subdomains/subdomains.txt | sed '/^$/d' | wc -l)
	end_subfunc "${NUMOFLINES} new subs (bruteforce)" ${FUNCNAME[0]}
else
	if [ "$SUBBRUTE" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi