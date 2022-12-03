#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$URL_GF" = true ]; then
	start_func ${FUNCNAME[0]} "Vulnerable Pattern Search"
	mkdir -p gf
	if [ -s "webs/url_extract.txt" ]; then
		gf xss webs/url_extract.txt | anew -q gf/xss.txt
		gf ssti webs/url_extract.txt | anew -q gf/ssti.txt
		gf ssrf webs/url_extract.txt | anew -q gf/ssrf.txt
		gf sqli webs/url_extract.txt | anew -q gf/sqli.txt
		gf redirect webs/url_extract.txt | anew -q gf/redirect.txt
		[ -s "gf/ssrf.txt" ] && cat gf/ssrf.txt | anew -q gf/redirect.txt
		gf rce webs/url_extract.txt | anew -q gf/rce.txt
		gf potential webs/url_extract.txt | cut -d ':' -f3-5 |anew -q gf/potential.txt
		[ -s ".tmp/url_extract_tmp.txt" ] && cat .tmp/url_extract_tmp.txt | grep -aEiv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)$" | unfurl -u format %s://%d%p 2>>"$LOGFILE" | anew -q gf/endpoints.txt
		gf lfi webs/url_extract.txt | anew -q gf/lfi.txt
	fi
	end_func "Results are saved in $domain/gf folder" ${FUNCNAME[0]}
else
	if [ "$URL_GF" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi