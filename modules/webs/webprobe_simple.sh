#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$WEBPROBESIMPLE" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Http probing $domain"
	if [ ! "$AXIOM" = true ]; then
		cat subdomains/subdomains.txt | httpx ${HTTPX_FLAGS} -no-color -json -H "${HEADER}" -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -retries 2 -timeout $HTTPX_TIMEOUT -o .tmp/web_full_info_probe.txt 2>>"$LOGFILE" &>/dev/null
	else
		axiom-scan subdomains/subdomains.txt -m httpx ${HTTPX_FLAGS} -no-color -json -H \"${HEADER}\" -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -retries 2 -timeout $HTTPX_TIMEOUT -o .tmp/web_full_info_probe.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	cat .tmp/web_full_info.txt .tmp/web_full_info_probe.txt webs/web_full_info.txt 2>>"$LOGFILE" | jq -s 'try .' | jq 'try unique_by(.input)' | jq 'try .[]' 2>>"$LOGFILE" > webs/web_full_info.txt
	cat webs/web_full_info.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew -q .tmp/probed_tmp.txt
	deleteOutScoped $outOfScope_file .tmp/probed_tmp.txt
	NUMOFLINES=$(cat .tmp/probed_tmp.txt 2>>"$LOGFILE" | anew webs/webs.txt | sed '/^$/d' | wc -l)
	cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	end_subfunc "${NUMOFLINES} new websites resolved" ${FUNCNAME[0]}
	if [ "$PROXY" = true ] && [ -n "$proxy_url" ] && [[ $(cat webs/webs.txt| wc -l) -le $DEEP_LIMIT2 ]]; then
		notification "Sending websites to proxy" info
		ffuf -mc all -w webs/webs.txt -u FUZZ -replay-proxy $proxy_url 2>>"$LOGFILE" &>/dev/null
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "webs/webs.txt" ] && cat webs/webs.txt | bbrf url add - 2>>"$LOGFILE" &>/dev/null
	fi
else
	if [ "$WEBPROBESIMPLE" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi