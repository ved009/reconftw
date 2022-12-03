#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUBNOERROR" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Checking NOERROR DNS response"
	if [[ $(echo "${RANDOM}thistotallynotexist${RANDOM}.$domain" | dnsx -r $resolvers -rcode noerror,nxdomain -retry 3 -silent | cut -d' ' -f2) == "[NXDOMAIN]" ]]; then 
		resolvers_update_quick_local
		if [ "$DEEP" = true ]; then
			dnsx -d $domain -r $resolvers -silent -rcode noerror -w $subs_wordlist_big | cut -d' ' -f1 | anew -q .tmp/subs_noerror.txt 2>>"$LOGFILE" &>/dev/null
		else
			dnsx -d $domain -r $resolvers -silent -rcode noerror -w $subs_wordlist | cut -d' ' -f1 | anew -q .tmp/subs_noerror.txt 2>>"$LOGFILE" &>/dev/null
		fi
		[[ "$INSCOPE" = true ]] && check_inscope .tmp/subs_noerror.txt 2>>"$LOGFILE" &>/dev/null
		NUMOFLINES=$(cat .tmp/subs_noerror.txt 2>>"$LOGFILE" | sed "s/*.//" | grep ".$domain$" | anew subdomains/subdomains.txt | sed '/^$/d' | wc -l)
		end_subfunc "${NUMOFLINES} new subs (DNS noerror)" ${FUNCNAME[0]}
	else 
		printf "\n${yellow} Detected DNSSEC black lies, skipping this technique ${reset}\n" 
	fi
else
	if [ "$SUBBRUTE" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi