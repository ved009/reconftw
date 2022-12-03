#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$EMAILS" = true ] && [ "$OSINT" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "Searching emails/users/passwords leaks"
	emailfinder -d $domain 2>>"$LOGFILE" | anew -q .tmp/emailfinder.txt
	[ -s ".tmp/emailfinder.txt" ] && cat .tmp/emailfinder.txt | grep "@" | grep -iv "|_" | anew -q osint/emails.txt
	cd "$tools/theHarvester" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	python3 theHarvester.py -d $domain -b all -f $dir/.tmp/harvester.json 2>>"$LOGFILE" &>/dev/null
	cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	if [ -s ".tmp/harvester.json" ]; then
		cat .tmp/harvester.json | jq -r 'try .emails[]' 2>/dev/null | anew -q osint/emails.txt
		cat .tmp/harvester.json | jq -r 'try .linkedin_people[]' 2>/dev/null | anew -q osint/employees.txt
		cat .tmp/harvester.json | jq -r 'try .linkedin_links[]' 2>/dev/null | anew -q osint/linkedin.txt
	fi
	h8mail -t $domain -q domain --loose -c $tools/h8mail_config.ini -j .tmp/h8_results.json 2>>"$LOGFILE" &>/dev/null
	[ -s ".tmp/h8_results.json" ] && cat .tmp/h8_results.json | jq -r '.targets[0] | .data[] | .[]' | awk '{print $12}' | anew -q osint/h8mail.txt
	PWNDB_STATUS=$(timeout 30s curl -Is --socks5-hostname localhost:9050 http://pwndb2am4tzkvold.onion | grep HTTP | cut -d ' ' -f2)
	if [ "$PWNDB_STATUS" = 200 ]; then
		cd "$tools/pwndb" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
		python3 pwndb.py --target "@${domain}" | sed '/^[-]/d' | anew -q $dir/osint/passwords.txt
		cd "$dir" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
		[ -s "osint/passwords.txt" ] && sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" osint/passwords.txt
		[ -s "osint/passwords.txt" ] && sed -i '1,2d' osint/passwords.txt
	else
		text="${yellow}\n pwndb is currently down :(\n\n Check xjypo5vzgmo7jca6b322dnqbsdnp3amd24ybx26x5nxbusccjkm4pwid.onion${reset}\n"
		printf "${text}" && printf "${text}" | $NOTIFY
	fi
	end_func "Results are saved in $domain/osint/[emails/users/h8mail/passwords].txt" ${FUNCNAME[0]}
else
	if [ "$EMAILS" = false ] || [ "$OSINT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$EMAILS" = false ] || [ "$OSINT" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi