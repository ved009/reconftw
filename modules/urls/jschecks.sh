#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$JSCHECKS" = true ]; then
	start_func ${FUNCNAME[0]} "Javascript Scan"
	if [ -s "js/url_extract_js.txt" ]; then
		printf "${yellow} Running : Fetching Urls 1/5${reset}\n"
		if [ ! "$AXIOM" = true ]; then
			cat js/url_extract_js.txt | subjs -ua "Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -c 40 | grep "$domain" | anew -q .tmp/subjslinks.txt
		else
			axiom-scan js/url_extract_js.txt -m subjs -o .tmp/subjslinks.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null							
		fi
		[ -s ".tmp/subjslinks.txt" ] && cat .tmp/subjslinks.txt | egrep -iv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)" | anew -q js/nojs_links.txt
		[ -s ".tmp/subjslinks.txt" ] && cat .tmp/subjslinks.txt | grep -iE "\.js" | anew -q js/url_extract_js.txt
		printf "${yellow} Running : Resolving JS Urls 2/5${reset}\n"
		if [ ! "$AXIOM" = true ]; then
			[ -s "js/url_extract_js.txt" ] && cat js/url_extract_js.txt | httpx -follow-redirects -random-agent -silent -timeout $HTTPX_TIMEOUT -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -status-code -retries 2 -no-color | grep "[200]" | cut -d ' ' -f1 | anew -q js/js_livelinks.txt
		else
			[ -s "js/url_extract_js.txt" ] && axiom-scan js/url_extract_js.txt -m httpx -follow-host-redirects -H \"${HEADER}\" -status-code -threads $HTTPX_THREADS -rl $HTTPX_RATELIMIT -timeout $HTTPX_TIMEOUT -silent -retries 2 -no-color -o .tmp/js_livelinks.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			[ -s ".tmp/js_livelinks.txt" ] && cat .tmp/js_livelinks.txt | anew .tmp/web_full_info.txt | grep "[200]" | cut -d ' ' -f1 | anew -q js/js_livelinks.txt
		fi
		printf "${yellow} Running : Gathering endpoints 3/5${reset}\n"
		[ -s "js/js_livelinks.txt" ] && python3 $tools/xnLinkFinder/xnLinkFinder.py -i js/js_livelinks.txt -sf subdomains/subdomains.txt -d $XNLINKFINDER_DEPTH -o .tmp/js_endpoints.txt &>/dev/null
		if [ -s ".tmp/js_endpoints.txt" ]; then
			sed -i '/^\//!d' .tmp/js_endpoints.txt
			cat .tmp/js_endpoints.txt | anew -q js/js_endpoints.txt
		fi
		printf "${yellow} Running : Gathering secrets 4/5${reset}\n"
		if [ ! "$AXIOM" = true ]; then
			[ -s "js/js_livelinks.txt" ] && cat js/js_livelinks.txt | nuclei -silent -t ~/nuclei-templates/ $NUCLEI_FLAGS_JS -r $resolvers_trusted -retries 3 -rl $NUCLEI_RATELIMIT -o js/js_secrets.txt 2>>"$LOGFILE" &>/dev/null
		else
			[ -s "js/js_livelinks.txt" ] && axiom-scan js/js_livelinks.txt -m nuclei $NUCLEI_FLAGS_JS -retries 3 -rl $NUCLEI_RATELIMIT -o js/js_secrets.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		printf "${yellow} Running : Building wordlist 5/5${reset}\n"
		[ -s "js/js_livelinks.txt" ] && rush -j ${INTERLACE_THREADS} -i js/js_livelinks.txt "python3 $tools/getjswords.py '{}' | anew -q webs/dict_words.txt" &>/dev/null
		#[ -s "js/js_livelinks.txt" ] && interlace -tL js/js_livelinks.txt -threads ${INTERLACE_THREADS}  -c "python3 $tools/getjswords.py '_target_' | anew -q webs/dict_words.txt" &>/dev/null
		end_func "Results are saved in $domain/js folder" ${FUNCNAME[0]}
	else
		end_func "No JS urls found for $domain, function skipped" ${FUNCNAME[0]}
	fi
else
	if [ "$JSCHECKS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi