#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$CDN_IP" = true ]; then
	start_func ${FUNCNAME[0]} "CDN provider check"
	[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try . | .a[]' | grep -aEiv "^(127|10|169\.154|172\.1[6789]|172\.2[0-9]|172\.3[01]|192\.168)\." | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u > .tmp/ips_cdn.txt
	[ -s ".tmp/ips_cdn.txt" ] && cat .tmp/ips_cdn.txt | ipcdn -m all | anew -q $dir/hosts/cdn_providers.txt
	end_func "Results are saved in hosts/cdn_providers.txt" ${FUNCNAME[0]}
else
	if [ "$CDN_IP" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi