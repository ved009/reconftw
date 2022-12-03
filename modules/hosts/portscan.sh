#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$PORTSCANNER" = true ]; then
	start_func ${FUNCNAME[0]} "Port scan"
	if ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try . | "\(.host) \(.a[0])"' | anew -q .tmp/subs_ips.txt
		[ -s ".tmp/subs_ips.txt" ] && awk '{ print $2 " " $1}' .tmp/subs_ips.txt | sort -k2 -n | anew -q hosts/subs_ips_vhosts.txt
		[ -s "hosts/subs_ips_vhosts.txt" ] && cat hosts/subs_ips_vhosts.txt | cut -d ' ' -f1 | grep -aEiv "^(127|10|169\.154|172\.1[6789]|172\.2[0-9]|172\.3[01]|192\.168)\." | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | anew -q hosts/ips.txt
	else echo $domain | grep -aEiv "^(127|10|169\.154|172\.1[6789]|172\.2[0-9]|172\.3[01]|192\.168)\." | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | anew -q hosts/ips.txt
	fi
	[ -s "hosts/ips.txt" ] && cat hosts/ips.txt | ipcdn -m not | grep -aEiv "^(127|10|169\.154|172\.1[6789]|172\.2[0-9]|172\.3[01]|192\.168)\." | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | anew -q .tmp/ips_nocdn.txt
	printf "${bblue}\n Resolved IP addresses (No CDN) ${reset}\n\n";
	[ -s ".tmp/ips_nocdn.txt" ] && cat .tmp/ips_nocdn.txt | sort
	printf "${bblue}\n Scanning ports... ${reset}\n\n";
	if [ "$PORTSCAN_PASSIVE" = true ] && [ ! -f "hosts/portscan_passive.txt" ] && [ -s ".tmp/ips_nocdn.txt" ] ; then
		smap -iL .tmp/ips_nocdn.txt > hosts/portscan_passive.txt
	fi
	if [ "$PORTSCAN_ACTIVE" = true ]; then
		if [ ! "$AXIOM" = true ]; then
			[ -s ".tmp/ips_nocdn.txt" ] && $SUDO nmap --top-ports 200 -sV -n --max-retries 2 -Pn --open -iL .tmp/ips_nocdn.txt -oA hosts/portscan_active 2>>"$LOGFILE" &>/dev/null
		else
			[ -s ".tmp/ips_nocdn.txt" ] && axiom-scan .tmp/ips_nocdn.txt -m nmapx --top-ports 200 -sV -n -Pn --open --max-retries 2 -o hosts/portscan_active.gnmap $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			[ -s "hosts/portscan_active.gnmap" ] && cat hosts/portscan_active.gnmap | egrep -v "^#|Status: Up" | cut -d' ' -f2,4- | sed -n -e 's/Ignored.*//p' | awk '{print "Host: " $1 " Ports: " NF-1; $1=""; for(i=2; i<=NF; i++) { a=a" "$i; }; split(a,s,","); for(e in s) { split(s[e],v,"/"); printf "%-8s %s/%-7s %s\n" , v[2], v[3], v[1], v[5]}; a="" }' > hosts/portscan_active.txt 2>>"$LOGFILE" &>/dev/null
		fi
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "hosts/subs_ips_vhosts.txt" ] && cat hosts/subs_ips_vhosts.txt | awk '{print $2,$1}' | sed -e 's/\s\+/:/g' | bbrf domain add -
		[ -s "hosts/subs_ips_vhosts.txt" ] && cat hosts/subs_ips_vhosts.txt | sed -e 's/\s\+/:/g' | bbrf ip add -
		[ -s "hosts/portscan_active.xml" ] && $tools/ultimate-nmap-parser/ultimate-nmap-parser.sh hosts/portscan_active.gnmap --csv 2>>"$LOGFILE" &>/dev/null
		[ -s "parsed_nmap.csv" ] && mv parsed_nmap.csv .tmp/parsed_nmap.csv && cat .tmp/parsed_nmap.csv | tail -n +2 | cut -d',' -f1,2,5,6 | sed -e 's/,/:/g' | sed 's/\:$//' | bbrf service add - && rm -f parsed_nmap.csv
	fi
	[ -s "hosts/portscan_active.xml" ] && searchsploit --nmap hosts/portscan_active.xml 2>/dev/null > hosts/searchsploit.txt
	end_func "Results are saved in hosts/portscan_[passive|active].txt" ${FUNCNAME[0]}
else
	if [ "$PORTSCANNER" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi