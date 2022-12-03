#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$CRLF_CHECKS" = true ]; then
	start_func ${FUNCNAME[0]} "CRLF checks"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ "$DEEP" = true ] || [[ $(cat .tmp/webs_all.txt | wc -l) -le $DEEP_LIMIT ]]; then
		crlfuzz -l .tmp/webs_all.txt -o vulns/crlf.txt 2>>"$LOGFILE" &>/dev/null
		end_func "Results are saved in vulns/crlf.txt" ${FUNCNAME[0]}
	else
		end_func "Skipping CRLF: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
else
	if [ "$CRLF_CHECKS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi