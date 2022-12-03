#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBTAKEOVER" = true ]; then
	start_func ${FUNCNAME[0]} "Looking for possible subdomain and DNS takeover"
	touch .tmp/tko.txt
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ ! "$AXIOM" = true ]; then
		cat subdomains/subdomains.txt .tmp/webs_all.txt 2>/dev/null | nuclei -silent -tags takeover -severity low,medium,high,critical -r $resolvers_trusted -retries 3 -rl $NUCLEI_RATELIMIT -o .tmp/tko.txt
	else
		cat subdomains/subdomains.txt .tmp/webs_all.txt 2>>"$LOGFILE" | sed '/^$/d' | anew -q .tmp/webs_subs.txt
		[ -s ".tmp/webs_subs.txt" ] && axiom-scan .tmp/webs_subs.txt -m nuclei -tags takeover -severity low,medium,high,critical -retries 3 -rl $NUCLEI_RATELIMIT -o .tmp/tko.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	# DNS_TAKEOVER
	cat .tmp/subs_no_resolved.txt .tmp/subdomains_dns.txt .tmp/scrap_subs.txt .tmp/analytics_subs_clean.txt .tmp/passive_recursive.txt 2>/dev/null | anew -q .tmp/subs_dns_tko.txt
	cat .tmp/subs_dns_tko.txt 2>/dev/null | dnstake -c $DNSTAKE_THREADS -s 2>>"$LOGFILE" | sed '/^$/d' | anew -q .tmp/tko.txt
	sed -i '/^$/d' .tmp/tko.txt
	NUMOFLINES=$(cat .tmp/tko.txt 2>>"$LOGFILE" | anew webs/takeover.txt | sed '/^$/d' | wc -l)
	if [ "$NUMOFLINES" -gt 0 ]; then
		notification "${NUMOFLINES} new possible takeovers found" info
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "webs/takeover.txt" ] && cat webs/takeover.txt | grep -aEo 'https?://[^ ]+' | bbrf url add - -t subtko:true 2>>"$LOGFILE" &>/dev/null
	fi
	end_func "Results are saved in $domain/webs/takeover.txt" ${FUNCNAME[0]}
else
	if [ "$SUBTAKEOVER" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi