#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$PROTO_POLLUTION" = true ] ; then
	start_func ${FUNCNAME[0]} "Prototype Pollution checks"
	if [ "$DEEP" = true ] || [[ $(cat webs/url_extract.txt | wc -l) -le $DEEP_LIMIT ]]; then
		[ -s "webs/url_extract.txt" ] && ppfuzz -l webs/url_extract.txt -c $PPFUZZ_THREADS 2>/dev/null | anew -q .tmp/prototype_pollution.txt
		[ -s ".tmp/prototype_pollution.txt" ] && cat .tmp/prototype_pollution.txt | sed -e '1,8d' | sed '/^\[ERR/d' | anew -q vulns/prototype_pollution.txt
		end_func "Results are saved in vulns/prototype_pollution.txt" ${FUNCNAME[0]}
	else
		end_func "Skipping Prototype Pollution: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
	fi
else
	if [ "$PROTO_POLLUTION" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi