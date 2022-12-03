#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUB_RECURSIVE_PASSIVE" = true ] && [ -s "subdomains/subdomains.txt" ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Subdomains recursive search passive"
	# Passive recursive
	[ -s "subdomains/subdomains.txt" ] && dsieve -if subdomains/subdomains.txt -f 3 -top $DEEP_RECURSIVE_PASSIVE > .tmp/subdomains_recurs_top.txt
	if [ ! "$AXIOM" = true ]; then
		resolvers_update_quick_local
		[ -s ".tmp/subdomains_recurs_top.txt" ] && amass enum -passive -df .tmp/subdomains_recurs_top.txt -nf subdomains/subdomains.txt -config $AMASS_CONFIG -timeout $AMASS_ENUM_TIMEOUT 2>>"$LOGFILE" | anew -q .tmp/passive_recursive.txt
		[ -s ".tmp/passive_recursive.txt" ] && puredns resolve .tmp/passive_recursive.txt -w .tmp/passive_recurs_tmp.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
	else
		resolvers_update_quick_axiom
		[ -s ".tmp/subdomains_recurs_top.txt" ] && axiom-scan .tmp/subdomains_recurs_top.txt -m amass -passive -o .tmp/amass_prec.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		[ -s ".tmp/amass_prec.txt" ] &&  cat .tmp/amass_prec.txt | anew -q .tmp/passive_recursive.txt
		[ -s ".tmp/passive_recursive.txt" ] && axiom-scan .tmp/passive_recursive.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/passive_recurs_tmp.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/passive_recurs_tmp.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/passive_recurs_tmp.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | sed '/^$/d' | anew subdomains/subdomains.txt | wc -l)
	end_subfunc "${NUMOFLINES} new subs (recursive)" ${FUNCNAME[0]}
else
	if [ "$SUB_RECURSIVE_PASSIVE" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi