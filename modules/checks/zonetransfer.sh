#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$ZONETRANSFER" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Zone transfer check"
	for ns in $(dig +short ns "$domain"); do dig axfr "$domain" @"$ns" >> subdomains/zonetransfer.txt; done
	if [ -s "subdomains/zonetransfer.txt" ]; then
		if ! grep -q "Transfer failed" subdomains/zonetransfer.txt ; then notification "Zone transfer found on ${domain}!" info; fi
	fi
	end_func "Results are saved in $domain/subdomains/zonetransfer.txt" ${FUNCNAME[0]}
else
	if [ "$ZONETRANSFER" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$ZONETRANSFER" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi