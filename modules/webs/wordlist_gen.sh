#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$WORDLIST" = true ];	then
	start_func ${FUNCNAME[0]} "Wordlist generation"
	if [ -s ".tmp/url_extract_tmp.txt" ]; then
		cat .tmp/url_extract_tmp.txt | unfurl -u keys 2>>"$LOGFILE" | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q webs/dict_params.txt
		cat .tmp/url_extract_tmp.txt | unfurl -u values 2>>"$LOGFILE" | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q webs/dict_values.txt
		cat .tmp/url_extract_tmp.txt | tr "[:punct:]" "\n" | anew -q webs/dict_words.txt
	fi
	[ -s ".tmp/js_endpoints.txt" ] && cat .tmp/js_endpoints.txt | unfurl -u format %s://%d%p 2>>"$LOGFILE" | anew -q webs/all_paths.txt
	[ -s ".tmp/url_extract_tmp.txt" ] && cat .tmp/url_extract_tmp.txt | unfurl -u format %s://%d%p 2>>"$LOGFILE" | anew -q webs/all_paths.txt
	end_func "Results are saved in $domain/webs/dict_[words|paths].txt" ${FUNCNAME[0]}
	if [ "$PROXY" = true ] && [ -n "$proxy_url" ] && [[ $(cat webs/all_paths.txt | wc -l) -le $DEEP_LIMIT2 ]]; then
		notification "Sending urls to proxy" info
		ffuf -mc all -w webs/all_paths.txt -u FUZZ -replay-proxy $proxy_url 2>>"$LOGFILE" &>/dev/null
	fi
else
	if [ "$WORDLIST" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi