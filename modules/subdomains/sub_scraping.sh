#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBSCRAPING" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Source code scraping subdomain search"
	touch .tmp/scrap_subs.txt
	if [ -s "$dir/subdomains/subdomains.txt" ]; then
		if [[ $(cat subdomains/subdomains.txt | wc -l) -le $DEEP_LIMIT ]] || [ "$DEEP" = true ] ; then
			if [ ! "$AXIOM" = true ]; then
				resolvers_update_quick_local
				cat subdomains/subdomains.txt | httpx -follow-host-redirects -H "${HEADER}" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info1.txt 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info1.txt" ] && cat .tmp/web_full_info1.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
				[ -s ".tmp/probed_tmp_scrap.txt" ] && cat .tmp/probed_tmp_scrap.txt | httpx -tls-grab -tls-probe -csp-probe -H "${HEADER}" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info2.txt 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info2.txt" ] && cat .tmp/web_full_info2.txt | jq -r 'try ."tls-grab"."dns_names"[],try .csp.domains[],try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | sort -u | httpx -silent | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
				if [ "$DEEP" = true ]; then
					[ -s ".tmp/probed_tmp_scrap.txt" ] && gospider -S .tmp/probed_tmp_scrap.txt --js -t $GOSPIDER_THREADS -d 3 --sitemap --robots -w -r > .tmp/gospider.txt
				else
					[ -s ".tmp/probed_tmp_scrap.txt" ] && gospider -S .tmp/probed_tmp_scrap.txt --js -t $GOSPIDER_THREADS -d 2 --sitemap --robots -w -r > .tmp/gospider.txt
				fi
				sed -i '/^.\{2048\}./d' .tmp/gospider.txt
				[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | unfurl -u domains 2>>"$LOGFILE" | grep ".$domain$" | anew -q .tmp/scrap_subs.txt
				[ -s ".tmp/scrap_subs.txt" ] && puredns resolve .tmp/scrap_subs.txt -w .tmp/scrap_subs_resolved.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
				if [ "$INSCOPE" = true ]; then
					check_inscope .tmp/scrap_subs_resolved.txt 2>>"$LOGFILE" &>/dev/null
				fi
				NUMOFLINES=$(cat .tmp/scrap_subs_resolved.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | anew subdomains/subdomains.txt | tee .tmp/diff_scrap.txt | sed '/^$/d' | wc -l)
				[ -s ".tmp/diff_scrap.txt" ] && cat .tmp/diff_scrap.txt | httpx -follow-host-redirects -H "${HEADER}" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info3.txt 2>>"$LOGFILE" &>/dev/null
			else
				resolvers_update_quick_axiom
				axiom-scan subdomains/subdomains.txt -m httpx -follow-host-redirects -H \"${HEADER}\" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info1.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info1.txt" ] && cat .tmp/web_full_info1.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
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
				[ -s ".tmp/scrap_subs.txt" ] && axiom-scan .tmp/scrap_subs.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/scrap_subs_resolved.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[[ "$INSCOPE" = true ]] && check_inscope .tmp/scrap_subs_resolved.txt 2>>"$LOGFILE" &>/dev/null
				NUMOFLINES=$(cat .tmp/scrap_subs_resolved.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | anew subdomains/subdomains.txt | tee .tmp/diff_scrap.txt | sed '/^$/d' | wc -l)
				[ -s ".tmp/diff_scrap.txt" ] && axiom-scan .tmp/diff_scrap.txt -m httpx -follow-host-redirects -H \"${HEADER}\" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info3.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			fi
			[ -s ".tmp/web_full_info3.txt" ] && cat .tmp/web_full_info3.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew .tmp/probed_tmp_scrap.txt | unfurl -u domains 2>>"$LOGFILE" | anew -q .tmp/scrap_subs.txt
			cat .tmp/web_full_info1.txt .tmp/web_full_info2.txt .tmp/web_full_info3.txt 2>>"$LOGFILE" | jq -s 'try .' | jq 'try unique_by(.input)' | jq 'try .[]' 2>>"$LOGFILE" > .tmp/web_full_info.txt
			end_subfunc "${NUMOFLINES} new subs (code scraping)" ${FUNCNAME[0]}
		else
			end_subfunc "Skipping Subdomains Web Scraping: Too Many Subdomains" ${FUNCNAME[0]}
		fi
	else
		end_subfunc "No subdomains to search (code scraping)" ${FUNCNAME[0]}
	fi
else
	if [ "$SUBSCRAPING" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi