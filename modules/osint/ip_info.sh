#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$IP_INFO" = true ] && [ "$OSINT" = true ] && [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Searching ip info"
	if [ -n "$WHOISXML_API" ]; then
		curl "https://reverse-ip.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ip=${domain}" 2>/dev/null | jq -r '.result[].name' 2>>"$LOGFILE" | sed -e "s/$/ ${ip}/" | anew -q osint/ip_${domain}_relations.txt
		curl "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=${WHOISXML_API}&domainName=${domain}&outputFormat=json&da=2&registryRawText=1&registrarRawText=1&ignoreRawTexts=1" 2>/dev/null | jq 2>>"$LOGFILE" | anew -q osint/ip_${domain}_whois.txt
		curl "https://ip-geolocation.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ipAddress=${domain}" 2>/dev/null | jq -r '.ip,.location' 2>>"$LOGFILE" | anew -q osint/ip_${domain}_location.txt
		end_func "Results are saved in $domain/osint/ip_[domain_relations|whois|location].txt" ${FUNCNAME[0]}
	else
		printf "\n${yellow} No WHOISXML_API var defined, skipping function ${reset}\n"
	fi
else
	if [ "$IP_INFO" = false ] || [ "$OSINT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ ! $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$IP_INFO" = false ] || [ "$OSINT" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi