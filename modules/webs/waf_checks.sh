#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$WAF_DETECTION" = true ]; then
	start_func ${FUNCNAME[0]} "Website's WAF detection"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ -s ".tmp/webs_all.txt" ]; then
		if [ ! "$AXIOM" = true ]; then
			wafw00f -i .tmp/webs_all.txt -o .tmp/wafs.txt 2>>"$LOGFILE" &>/dev/null
		else
			axiom-scan .tmp/webs_all.txt -m wafw00f -o .tmp/wafs.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		if [ -s ".tmp/wafs.txt" ]; then
			cat .tmp/wafs.txt | sed -e 's/^[ \t]*//' -e 's/ \+ /\t/g' -e '/(None)/d' | tr -s "\t" ";" > webs/webs_wafs.txt
			NUMOFLINES=$(cat webs/webs_wafs.txt 2>>"$LOGFILE" | sed '/^$/d' | wc -l)
			notification "${NUMOFLINES} websites protected by waf" info
			if [ "$BBRF_CONNECTION" = true ]; then
				[ -s "webs/webs_wafs.txt" ] && cat webs/webs_wafs.txt | bbrf url add - -t waf:true 2>>"$LOGFILE" &>/dev/null
			fi
			end_func "Results are saved in $domain/webs/webs_wafs.txt" ${FUNCNAME[0]}
		else
			end_func "No results found" ${FUNCNAME[0]}
		fi
	else
		end_func "No websites to scan" ${FUNCNAME[0]}
	fi
else
	if [ "$WAF_DETECTION" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi