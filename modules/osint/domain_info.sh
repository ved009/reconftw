#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$DOMAIN_INFO" = true ] && [ "$OSINT" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Searching domain info (whois, registrant name/email domains)"
	whois -H $domain > osint/domain_info_general.txt
	if [ "$DEEP" = true ] || [ "$REVERSE_WHOIS" = true ]; then
		amass intel -d ${domain} -whois -timeout $AMASS_INTEL_TIMEOUT -o osint/domain_info_reverse_whois.txt 2>>"$LOGFILE" &>/dev/null
	fi
	end_func "Results are saved in $domain/osint/domain_info_[general/name/email/ip].txt" ${FUNCNAME[0]}
else
	if [ "$DOMAIN_INFO" = false ] || [ "$OSINT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$DOMAIN_INFO" = false ] || [ "$OSINT" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi