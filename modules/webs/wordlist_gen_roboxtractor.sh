#!/usr/bin/env bash

if  { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$ROBOTSWORDLIST" = true ]; then
	start_func ${FUNCNAME[0]} "Robots wordlist generation"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ -s ".tmp/webs_all.txt" ]; then
		cat .tmp/webs_all.txt | roboxtractor -m 1 -wb 2>/dev/null | anew -q webs/robots_wordlist.txt
	fi
	end_func "Results are saved in $domain/webs/robots_wordlist.txt" ${FUNCNAME[0]}
else
	if [ "$ROBOTSWORDLIST" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi