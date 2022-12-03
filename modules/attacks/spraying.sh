#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SPRAY" = true ]; then
	start_func ${FUNCNAME[0]} "Password spraying"
	cd "$tools/brutespray" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	python3 brutespray.py --file $dir/hosts/portscan_active.gnmap --threads $BRUTESPRAY_THREADS --hosts $BRUTESPRAY_CONCURRENCE -o $dir/vulns/brutespray 2>>"$LOGFILE" &>/dev/null
	cd "$dir" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	end_func "Results are saved in vulns/brutespray folder" ${FUNCNAME[0]}
else
	if [ "$SPRAY" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi