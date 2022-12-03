#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$BROKENLINKS" = true ] ; then
	start_func ${FUNCNAME[0]} "Broken links checks"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ ! "$AXIOM" = true ]; then
		if [ ! -s ".tmp/gospider.txt" ]; then
			if [ "$DEEP" = true ]; then
				[ -s ".tmp/webs_all.txt" ] && gospider -S .tmp/webs_all.txt --js -t $GOSPIDER_THREADS -d 3 --sitemap --robots -w -r > .tmp/gospider.txt
			else
				[ -s ".tmp/webs_all.txt" ] && gospider -S .tmp/webs_all.txt --js -t $GOSPIDER_THREADS -d 2 --sitemap --robots -w -r > .tmp/gospider.txt
			fi
		fi
		[ -s ".tmp/gospider.txt" ] && sed -i '/^.\{2048\}./d' .tmp/gospider.txt
	else
		if [ ! -s ".tmp/gospider.txt" ]; then
			if [ "$DEEP" = true ]; then
				[ -s ".tmp/webs_all.txt" ] && axiom-scan .tmp/webs_all.txt -m gospider --js -d 3 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			else
				[ -s ".tmp/webs_all.txt" ] && axiom-scan .tmp/webs_all.txt -m gospider --js -d 2 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			fi
			find .tmp/gospider -type f -exec cat {} + | sed '/^.\{2048\}./d' | anew -q .tmp/gospider.txt
		fi
	fi
	[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | sort -u | httpx -follow-redirects -H "${HEADER}" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -no-color | grep "\[4" | cut -d ' ' -f1 | anew -q .tmp/brokenLinks_total.txt
	NUMOFLINES=$(cat .tmp/brokenLinks_total.txt 2>>"$LOGFILE" | anew vulns/brokenLinks.txt | sed '/^$/d' | wc -l)
	notification "${NUMOFLINES} new broken links found" info
	end_func "Results are saved in vulns/brokenLinks.txt" ${FUNCNAME[0]}
else
	if [ "$BROKENLINKS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi