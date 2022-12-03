#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$CORS" = true ]; then
	start_func ${FUNCNAME[0]} "CORS Scan"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	[ -s ".tmp/webs_all.txt" ] && python3 $tools/Corsy/corsy.py -i .tmp/webs_all.txt -o vulns/cors.txt 2>>"$LOGFILE" &>/dev/null
	end_func "Results are saved in vulns/cors.txt" ${FUNCNAME[0]}
else
	if [ "$CORS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi