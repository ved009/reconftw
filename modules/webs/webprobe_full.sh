#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$WEBPROBEFULL" = true ]; then
	start_func ${FUNCNAME[0]} "Http probing non standard ports"
	if [ -s "subdomains/subdomains.txt" ]; then
		if [ "$NMAP_WEBPROBE" = true ]; then
			if [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
				$SUDO nmap -iL subdomains/subdomains.txt -p $UNCOMMON_PORTS_WEB -oG .tmp/uncommon_nmap.gnmap 2>>"$LOGFILE" &>/dev/null
				cat .tmp/uncommon_nmap.gnmap | egrep -v "^#|Status: Up" | cut -d' ' -f2,4- | grep "open" | sed -e 's/\/.*$//g' | sed -e "s/ /:/g" | sort -u | anew -q .tmp/nmap_uncommonweb.txt
			else
				if [ ! "$AXIOM" = true ]; then
					$SUDO unimap --fast-scan -f subdomains/subdomains.txt --ports $UNCOMMON_PORTS_WEB -q -k --url-output 2>>"$LOGFILE" | anew -q .tmp/nmap_uncommonweb.txt
				else
					axiom-scan subdomains/subdomains.txt -m unimap --fast-scan --ports $UNCOMMON_PORTS_WEB -q -k --url-output -o .tmp/nmap_uncommonweb.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				fi
			fi
		fi
	fi
	if [ "$NMAP_WEBPROBE" = true ]; then
		if [ ! "$AXIOM" = true ]; then
			if [ -s ".tmp/nmap_uncommonweb.txt" ]; then
				cat .tmp/nmap_uncommonweb.txt | httpx -follow-host-redirects -H "${HEADER}" -status-code -threads $HTTPX_UNCOMMONPORTS_THREADS -timeout $HTTPX_UNCOMMONPORTS_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info_uncommon.txt 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info_uncommon.txt" ] && cat .tmp/web_full_info_uncommon.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew -q .tmp/probed_uncommon_ports_tmp.txt
			fi
		else
			if [ -s ".tmp/nmap_uncommonweb.txt" ]; then
				axiom-scan .tmp/nmap_uncommonweb.txt -m httpx -follow-host-redirects -H \"${HEADER}\" -status-code -threads $HTTPX_UNCOMMONPORTS_THREADS -timeout $HTTPX_UNCOMMONPORTS_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info_uncommon.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info_uncommon.txt" ] && cat .tmp/web_full_info_uncommon.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew -q .tmp/probed_uncommon_ports_tmp.txt
			fi
		fi
	else
		if [ ! "$AXIOM" = true ]; then
			if [ -s "subdomains/subdomains.txt" ]; then
				cat subdomains/subdomains.txt | httpx -follow-host-redirects -H "${HEADER}" -status-code -p $UNCOMMON_PORTS_WEB -threads $HTTPX_UNCOMMONPORTS_THREADS -timeout $HTTPX_UNCOMMONPORTS_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info_uncommon.txt 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info_uncommon.txt" ] && cat .tmp/web_full_info_uncommon.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew -q .tmp/probed_uncommon_ports_tmp.txt
			fi
		else
			if [ -s "subdomains/subdomains.txt" ]; then
				axiom-scan subdomains/subdomains.txt -m httpx -follow-host-redirects -H \"${HEADER}\" -status-code -p $UNCOMMON_PORTS_WEB -threads $HTTPX_UNCOMMONPORTS_THREADS -timeout $HTTPX_UNCOMMONPORTS_TIMEOUT -silent -retries 2 -title -web-server -tech-detect -location -no-color -json -o .tmp/web_full_info_uncommon.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/web_full_info_uncommon.txt" ] && cat .tmp/web_full_info_uncommon.txt | jq -r 'try .url' 2>/dev/null | grep "$domain" | sed "s/*.//" | anew -q .tmp/probed_uncommon_ports_tmp.txt
			fi
		fi
	fi
	if [ -s ".tmp/web_full_info_uncommon.txt" ]; then
		if [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then 
			cat .tmp/web_full_info_uncommon.txt 2>>"$LOGFILE" | anew -q webs/web_full_info_uncommon.txt
		else
			cat .tmp/web_full_info_uncommon.txt 2>>"$LOGFILE" | grep "$domain" | anew -q webs/web_full_info_uncommon.txt
		fi
	fi
	NUMOFLINES=$(cat .tmp/probed_uncommon_ports_tmp.txt 2>>"$LOGFILE" | anew webs/webs_uncommon_ports.txt | sed '/^$/d' | wc -l)
	notification "Uncommon web ports: ${NUMOFLINES} new websites" good
	[ -s "webs/webs_uncommon_ports.txt" ] && cat webs/webs_uncommon_ports.txt
	cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	rm -rf "unimap_logs" 2>>"$LOGFILE"
	end_func "Results are saved in $domain/webs/webs_uncommon_ports.txt" ${FUNCNAME[0]}
	if [ "$PROXY" = true ] && [ -n "$proxy_url" ] && [[ $(cat webs/webs_uncommon_ports.txt| wc -l) -le $DEEP_LIMIT2 ]]; then
		notification "Sending websites with uncommon ports to proxy" info
		ffuf -mc all -w webs/webs_uncommon_ports.txt -u FUZZ -replay-proxy $proxy_url 2>>"$LOGFILE" &>/dev/null
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "webs/webs_uncommon_ports.txt" ] && cat webs/webs_uncommon_ports.txt | bbrf url add - 2>>"$LOGFILE" &>/dev/null
	fi
else
	if [ "$WEBPROBEFULL" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi