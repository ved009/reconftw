#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$TEST_SSL" = true ]; then
	start_func ${FUNCNAME[0]} "SSL Test"
	$tools/testssl.sh/testssl.sh --quiet --color 0 -U -iL hosts/ips.txt 2>>"$LOGFILE" > vulns/testssl.txt
	end_func "Results are saved in vulns/testssl.txt" ${FUNCNAME[0]}
else
	if [ "$TEST_SSL" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi