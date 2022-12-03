#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$OPEN_REDIRECT" = true ] && [ -s "gf/redirect.txt" ]; then
	start_func ${FUNCNAME[0]} "Open redirects checks"
	if [ "$DEEP" = true ] || [[ $(cat gf/redirect.txt | wc -l) -le $DEEP_LIMIT ]]; then
		cat gf/redirect.txt | qsreplace FUZZ | sed '/FUZZ/!d' | anew -q .tmp/tmp_redirect.txt
		python3 $tools/Oralyzer/oralyzer.py -l .tmp/tmp_redirect.txt -p $tools/Oralyzer/payloads.txt > vulns/redirect.txt
		sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" vulns/redirect.txt
		end_func "Results are saved in vulns/redirect.txt" ${FUNCNAME[0]}
	else
		end_func "Skipping Open redirects: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
		printf "${bgreen}#######################################################################${reset}\n"
	fi
else
	if [ "$OPEN_REDIRECT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/redirect.txt" ]; then
		printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to Open Redirect ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi