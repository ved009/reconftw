#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBANALYTICS" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Analytics Subdomain Enumeration"
	if [ -s ".tmp/probed_tmp_scrap.txt" ]; then
		mkdir -p .tmp/output_analytics/
		cat .tmp/probed_tmp_scrap.txt | analyticsrelationships -ch >> .tmp/analytics_subs_tmp.txt 2>>"$LOGFILE" &>/dev/null
		[ -s ".tmp/analytics_subs_tmp.txt" ] && cat .tmp/analytics_subs_tmp.txt | grep "\.$domain$\|^$domain$" | sed "s/|__ //" | anew -q .tmp/analytics_subs_clean.txt
		if [ ! "$AXIOM" = true ]; then
			resolvers_update_quick_local
			[ -s ".tmp/analytics_subs_clean.txt" ] && puredns resolve .tmp/analytics_subs_clean.txt -w .tmp/analytics_subs_resolved.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
		else
			resolvers_update_quick_axiom
			[ -s ".tmp/analytics_subs_clean.txt" ] && axiom-scan .tmp/analytics_subs_clean.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/analytics_subs_resolved.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
	fi
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/analytics_subs_resolved.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/analytics_subs_resolved.txt 2>>"$LOGFILE" | anew subdomains/subdomains.txt | sed '/^$/d' | wc -l)
	end_subfunc "${NUMOFLINES} new subs (analytics relationship)" ${FUNCNAME[0]}
else
	if [ "$SUBANALYTICS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi