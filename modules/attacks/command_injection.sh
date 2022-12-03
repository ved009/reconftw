#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$COMM_INJ" = true ] && [ -s "gf/rce.txt" ]; then
	start_func ${FUNCNAME[0]} "Command Injection checks"
	[ -s "gf/rce.txt" ] && cat gf/rce.txt | qsreplace FUZZ | sed '/FUZZ/!d'  | anew -q .tmp/tmp_rce.txt
	if [ "$DEEP" = true ] || [[ $(cat .tmp/tmp_rce.txt | wc -l) -le $DEEP_LIMIT ]]; then
		[ -s ".tmp/tmp_rce.txt" ] && python3 $tools/commix/commix.py --batch -m .tmp/tmp_rce.txt --output-dir vulns/command_injection.txt 2>>"$LOGFILE" &>/dev/null
		end_func "Results are saved in vulns/command_injection folder" ${FUNCNAME[0]}
	else
		end_func "Skipping Command injection: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
else
	if [ "$COMM_INJ" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/rce.txt" ]; then
		printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to Command Injection ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi