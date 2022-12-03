#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$URL_CHECK" = true ]; then
	start_func ${FUNCNAME[0]} "URL Extraction"
	mkdir -p js
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ -s ".tmp/webs_all.txt" ]; then
		if [ ! "$AXIOM" = true ]; then
			if [ "$URL_CHECK_PASSIVE" = true ]; then
				cat .tmp/webs_all.txt | waybackurls -no-subs | anew -q .tmp/url_extract_tmp.txt
				cat .tmp/webs_all.txt | gau --threads $GAU_THREADS | anew -q .tmp/url_extract_tmp.txt
				if [ -s "${GITHUB_TOKENS}" ]; then
					github-endpoints -q -k -d $domain -t ${GITHUB_TOKENS} -o .tmp/github-endpoints.txt 2>>"$LOGFILE" &>/dev/null
					[ -s ".tmp/github-endpoints.txt" ] && cat .tmp/github-endpoints.txt | anew -q .tmp/url_extract_tmp.txt
				fi
			fi
			diff_webs=$(diff <(sort -u .tmp/probed_tmp.txt 2>>"$LOGFILE") <(sort -u .tmp/webs_all.txt 2>>"$LOGFILE") | wc -l)
			if [ $diff_webs != "0" ] || [ ! -s ".tmp/gospider.txt" ]; then
				if [ "$URL_CHECK_ACTIVE" = true ]; then
					if [ "$DEEP" = true ]; then
						gospider -S .tmp/webs_all.txt --js -t $GOSPIDER_THREADS -d 3 --sitemap --robots -w -r > .tmp/gospider.txt
					else
						gospider -S .tmp/webs_all.txt --js -t $GOSPIDER_THREADS -d 2 --sitemap --robots -w -r > .tmp/gospider.txt
					fi
				fi
			fi
			[ -s ".tmp/gospider.txt" ] && sed -i '/^.\{2048\}./d' .tmp/gospider.txt
			[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | grep -E "^(http|https):[\/]{2}([a-zA-Z0-9\-\.]+\.$domain)" | anew -q .tmp/url_extract_tmp.txt
		else
			if [ "$URL_CHECK_PASSIVE" = true ]; then
				axiom-scan .tmp/webs_all.txt -m waybackurls -o .tmp/url_extract_way_tmp.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/url_extract_way_tmp.txt" ] && cat .tmp/url_extract_way_tmp.txt | anew -q .tmp/url_extract_tmp.txt
				axiom-scan .tmp/webs_all.txt -m gau -o .tmp/url_extract_gau_tmp.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				[ -s ".tmp/url_extract_gau_tmp.txt" ] && cat .tmp/url_extract_gau_tmp.txt | anew -q .tmp/url_extract_tmp.txt
				if [ -s "${GITHUB_TOKENS}" ]; then
					github-endpoints -q -k -d $domain -t ${GITHUB_TOKENS} -o .tmp/github-endpoints.txt 2>>"$LOGFILE" &>/dev/null
					[ -s ".tmp/github-endpoints.txt" ] && cat .tmp/github-endpoints.txt | anew -q .tmp/url_extract_tmp.txt
				fi
			fi
			diff_webs=$(diff <(sort -u .tmp/probed_tmp.txt) <(sort -u .tmp/webs_all.txt) | wc -l)
			if [ $diff_webs != "0" ] || [ ! -s ".tmp/gospider.txt" ]; then
				if [ "$URL_CHECK_ACTIVE" = true ]; then
					if [ "$DEEP" = true ]; then
						axiom-scan .tmp/webs_all.txt -m gospider --js -d 3 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
					else
						axiom-scan .tmp/webs_all.txt -m gospider --js -d 2 --sitemap --robots -w -r -o .tmp/gospider $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
					fi	
					[[ -d .tmp/gospider/ ]] && find .tmp/gospider -type f -exec cat {} + | sed '/^.\{2048\}./d' | anew -q .tmp/gospider.txt
				fi
			fi
			[[ -d .tmp/gospider/ ]] && NUMFILES=$(find .tmp/gospider/ -type f | wc -l)
			[[ $NUMFILES -gt 0 ]] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | grep -E "^(http|https):[\/]{2}([a-zA-Z0-9\-\.]+\.$domain)" | anew -q .tmp/url_extract_tmp.txt
		fi
		[ -s ".tmp/url_extract_tmp.txt" ] && cat .tmp/url_extract_tmp.txt | grep "${domain}" | grep -aEi "\.(js)" | anew -q js/url_extract_js.txt
		if [ "$DEEP" = true ]; then
			[ -s "js/url_extract_js.txt" ] && cat js/url_extract_js.txt | python3 $tools/JSA/jsa.py | anew -q .tmp/url_extract_tmp.txt
		fi
		[ -s ".tmp/url_extract_tmp.txt" ] &&  cat .tmp/url_extract_tmp.txt | grep "${domain}" | grep "=" | qsreplace -a 2>>"$LOGFILE" | grep -aEiv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)$" | anew -q .tmp/url_extract_tmp2.txt
		[ -s ".tmp/url_extract_tmp2.txt" ] && cat .tmp/url_extract_tmp2.txt | $tools/urless/urless.py | anew -q .tmp/url_extract_uddup.txt 2>>"$LOGFILE" &>/dev/null
		NUMOFLINES=$(cat .tmp/url_extract_uddup.txt 2>>"$LOGFILE" | anew webs/url_extract.txt | sed '/^$/d' | wc -l)
		notification "${NUMOFLINES} new urls with params" info
		end_func "Results are saved in $domain/webs/url_extract.txt" ${FUNCNAME[0]}
		if [ "$PROXY" = true ] && [ -n "$proxy_url" ] && [[ $(cat webs/url_extract.txt | wc -l) -le $DEEP_LIMIT2 ]]; then
			notification "Sending urls to proxy" info
			ffuf -mc all -w webs/url_extract.txt -u FUZZ -replay-proxy $proxy_url 2>>"$LOGFILE" &>/dev/null
		fi
	fi
else
	if [ "$URL_CHECK" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi