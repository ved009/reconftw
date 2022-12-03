#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SQLI" = true ] && [ -s "gf/sqli.txt" ]; then
	start_func ${FUNCNAME[0]} "SQLi checks"
	cat gf/sqli.txt | qsreplace FUZZ | sed '/FUZZ/!d' | anew -q .tmp/tmp_sqli.txt
	if [ "$DEEP" = true ] || [[ $(cat .tmp/tmp_sqli.txt | wc -l) -le $DEEP_LIMIT ]]; then
		python3 /root/Tools/sqlmap/sqlmap.py -m .tmp/tmp_sqli.txt -b -o --smart --batch --disable-coloring --random-agent --output-dir=vulns/sqlmap &>/dev/null
		end_func "Results are saved in vulns/sqlmap folder" ${FUNCNAME[0]}
	else
		end_func "Skipping SQLi: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
else
	if [ "$SQLI" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/sqli.txt" ]; then
		printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to SQLi ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi