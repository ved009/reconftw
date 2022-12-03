#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$METADATA" = true ] && [ "$OSINT" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Scanning metadata in public files"
	metafinder -d "$domain" -l $METAFINDER_LIMIT -o osint -go -bi -ba 2>>"$LOGFILE" &>/dev/null
	mv "osint/${domain}/"*".txt" "osint/" 2>>"$LOGFILE"
	rm -rf "osint/${domain}" 2>>"$LOGFILE"
	end_func "Results are saved in $domain/osint/[software/authors/metadata_results].txt" ${FUNCNAME[0]}
else
	if [ "$METADATA" = false ] || [ "$OSINT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$METADATA" = false ] || [ "$OSINT" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi