#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SSRF_CHECKS" = true ] && [ -s "gf/ssrf.txt" ]; then
	start_func ${FUNCNAME[0]} "SSRF checks"
	if [ -z "$COLLAB_SERVER" ]; then
		interactsh-client &>.tmp/ssrf_callback.txt &
		sleep 2
		COLLAB_SERVER_FIX=$(cat .tmp/ssrf_callback.txt | tail -n1 | cut -c 16-)
		COLLAB_SERVER_URL="http://$COLLAB_SERVER_FIX"
		INTERACT=true
	else
		COLLAB_SERVER_FIX=$(echo ${COLLAB_SERVER} | sed -r "s/https?:\/\///")
		INTERACT=false
	fi
	if [ "$DEEP" = true ] || [[ $(cat gf/ssrf.txt | wc -l) -le $DEEP_LIMIT ]]; then
		cat gf/ssrf.txt | qsreplace ${COLLAB_SERVER_FIX} | anew -q .tmp/tmp_ssrf.txt
		cat gf/ssrf.txt | qsreplace ${COLLAB_SERVER_URL} | anew -q .tmp/tmp_ssrf.txt
		ffuf -v -H "${HEADER}" -t $FFUF_THREADS -rate $FFUF_RATELIMIT -w .tmp/tmp_ssrf.txt -u FUZZ 2>/dev/null | grep "URL" | sed 's/| URL | //' | anew -q vulns/ssrf_requested_url.txt
		ffuf -v -w .tmp/tmp_ssrf.txt:W1,$tools/headers_inject.txt:W2 -H "${HEADER}" -H "W2: ${COLLAB_SERVER_FIX}" -t $FFUF_THREADS -rate $FFUF_RATELIMIT -u W1 2>/dev/null | anew -q vulns/ssrf_requested_headers.txt
		ffuf -v -w .tmp/tmp_ssrf.txt:W1,$tools/headers_inject.txt:W2 -H "${HEADER}" -H "W2: ${COLLAB_SERVER_URL}" -t $FFUF_THREADS -rate $FFUF_RATELIMIT -u W1 2>/dev/null | anew -q vulns/ssrf_requested_headers.txt
		sleep 5
		[ -s ".tmp/ssrf_callback.txt" ] && cat .tmp/ssrf_callback.txt | tail -n+11 | anew -q vulns/ssrf_callback.txt && NUMOFLINES=$(cat .tmp/ssrf_callback.txt | tail -n+12 | sed '/^$/d' | wc -l)
		[ "$INTERACT" = true ] && notification "SSRF: ${NUMOFLINES} callbacks received" info
		end_func "Results are saved in vulns/ssrf_*" ${FUNCNAME[0]}
	else
		end_func "Skipping SSRF: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
	pkill -f interactsh-client &
else
	if [ "$SSRF_CHECKS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/ssrf.txt" ]; then
			printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to SSRF ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi