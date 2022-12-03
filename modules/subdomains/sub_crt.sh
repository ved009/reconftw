#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBCRT" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Crtsh Subdomain Enumeration"
	python3 $tools/ctfr/ctfr.py -d $domain -o .tmp/crtsh_subs_tmp.txt 2>>"$LOGFILE" &>/dev/null
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/crtsh_subs_tmp.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/crtsh_subs_tmp.txt 2>>"$LOGFILE" | sed 's/\*.//g' | anew .tmp/crtsh_subs.txt | sed '/^$/d' | wc -l)
	end_subfunc "${NUMOFLINES} new subs (cert transparency)" ${FUNCNAME[0]}
else
	if [ "$SUBCRT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi