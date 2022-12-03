#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$WEBSCREENSHOT" = true ]; then
	start_func ${FUNCNAME[0]} "Web Screenshots"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ ! "$AXIOM" = true ]; then
		[ -s ".tmp/webs_all.txt" ] && gowitness file -f .tmp/webs_all.txt -t $GOWITNESS_THREADS --disable-logging 2>>"$LOGFILE"
	else
		[ "$AXIOM_SCREENSHOT_MODULE" = "webscreenshot" ] && axiom-scan .tmp/webs_all.txt -m $AXIOM_SCREENSHOT_MODULE -w $WEBSCREENSHOT_THREADS -o screenshots $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		[ "$AXIOM_SCREENSHOT_MODULE" != "webscreenshot" ] && axiom-scan .tmp/webs_all.txt -m $AXIOM_SCREENSHOT_MODULE -o screenshots $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	end_func "Results are saved in $domain/screenshots folder" ${FUNCNAME[0]}
else
	if [ "$WEBSCREENSHOT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi