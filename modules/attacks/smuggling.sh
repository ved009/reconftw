#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SMUGGLING" = true ] ; then
	start_func ${FUNCNAME[0]} "HTTP Request Smuggling checks"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ "$DEEP" = true ] || [[ $(cat .tmp/webs_all.txt | wc -l) -le $DEEP_LIMIT ]]; then
		cd "$tools/smuggler" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
		cat $dir/.tmp/webs_all.txt | python3 smuggler.py -q --no-color 2>/dev/null | anew -q $dir/.tmp/smuggling.txt
		cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
		[ -s ".tmp/smuggling.txt" ] && cat .tmp/smuggling.txt | anew -q vulns/smuggling.txt
		end_func "Results are saved in vulns/smuggling.txt" ${FUNCNAME[0]}
	else
		end_func "Skipping Prototype Pollution: Too many webs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
else
	if [ "$SMUGGLING" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi