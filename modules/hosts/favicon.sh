#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$FAVICON" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Favicon Ip Lookup"
	cd "$tools/fav-up" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	python3 favUp.py -w "$domain" -sc -o favicontest.json 2>>"$LOGFILE" &>/dev/null
	if [ -s "favicontest.json" ]; then
		cat favicontest.json | jq -r 'try .found_ips' 2>>"$LOGFILE" | grep -v "not-found" > favicontest.txt
		sed -i "s/|/\n/g" favicontest.txt
		cat favicontest.txt 2>>"$LOGFILE"
		mv favicontest.txt $dir/hosts/favicontest.txt 2>>"$LOGFILE"
		rm -f favicontest.json 2>>"$LOGFILE"
	fi
	cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	end_func "Results are saved in hosts/favicontest.txt" ${FUNCNAME[0]}
else
	if [ "$FAVICON" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$FAVICON" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi