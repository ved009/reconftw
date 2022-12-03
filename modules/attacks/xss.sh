#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$XSS" = true ] && [ -s "gf/xss.txt" ]; then
	start_func ${FUNCNAME[0]} "XSS Analysis"
	[ -s "gf/xss.txt" ] && cat gf/xss.txt | qsreplace FUZZ | sed '/FUZZ/!d' | Gxss -c 100 -p Xss | qsreplace FUZZ | sed '/FUZZ/!d' | anew -q .tmp/xss_reflected.txt
	if [ ! "$AXIOM" = true ]; then		
		if [ "$DEEP" = true ]; then
			if [ -n "$XSS_SERVER" ]; then
				[ -s ".tmp/xss_reflected.txt" ] && cat .tmp/xss_reflected.txt | dalfox pipe --silence --no-color --no-spinner --only-poc r --ignore-return 302,404,403 --skip-bav -b ${XSS_SERVER} -w $DALFOX_THREADS 2>>"$LOGFILE" | anew -q vulns/xss.txt
			else
				printf "${yellow}\n No XSS_SERVER defined, blind xss skipped\n\n"
				[ -s ".tmp/xss_reflected.txt" ] && cat .tmp/xss_reflected.txt | dalfox pipe --silence --no-color --no-spinner --only-poc r --ignore-return 302,404,403 --skip-bav -w $DALFOX_THREADS 2>>"$LOGFILE" | anew -q vulns/xss.txt
			fi
		else
			if [[ $(cat .tmp/xss_reflected.txt | wc -l) -le $DEEP_LIMIT ]]; then
				if [ -n "$XSS_SERVER" ]; then
					cat .tmp/xss_reflected.txt | dalfox pipe --silence --no-color --no-spinner --skip-bav --skip-mining-dom --skip-mining-dict --only-poc r --ignore-return 302,404,403 -b ${XSS_SERVER} -w $DALFOX_THREADS 2>>"$LOGFILE" | anew -q vulns/xss.txt
				else
					printf "${yellow}\n No XSS_SERVER defined, blind xss skipped\n\n"
					cat .tmp/xss_reflected.txt | dalfox pipe --silence --no-color --no-spinner --skip-bav --skip-mining-dom --skip-mining-dict --only-poc r --ignore-return 302,404,403 -w $DALFOX_THREADS 2>>"$LOGFILE" | anew -q vulns/xss.txt
				fi
			else
				printf "${bred} Skipping XSS: Too many URLs to test, try with --deep flag${reset}\n"
			fi
		fi
	else
		if [ "$DEEP" = true ]; then
			if [ -n "$XSS_SERVER" ]; then
				[ -s ".tmp/xss_reflected.txt" ] && axiom-scan .tmp/xss_reflected.txt -m dalfox --skip-bav -b ${XSS_SERVER} -w $DALFOX_THREADS -o vulns/xss.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			else
				printf "${yellow}\n No XSS_SERVER defined, blind xss skipped\n\n"
				[ -s ".tmp/xss_reflected.txt" ] && axiom-scan .tmp/xss_reflected.txt -m dalfox --skip-bav -w $DALFOX_THREADS -o vulns/xss.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			fi
		else
			if [[ $(cat .tmp/xss_reflected.txt | wc -l) -le $DEEP_LIMIT ]]; then
				if [ -n "$XSS_SERVER" ]; then
					axiom-scan .tmp/xss_reflected.txt -m dalfox --skip-bav --skip-grepping --skip-mining-all --skip-mining-dict -b ${XSS_SERVER} -w $DALFOX_THREADS -o vulns/xss.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				else
					printf "${yellow}\n No XSS_SERVER defined, blind xss skipped\n\n"
					axiom-scan .tmp/xss_reflected.txt -m dalfox --skip-bav --skip-grepping --skip-mining-all --skip-mining-dict -w $DALFOX_THREADS -o vulns/xss.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
				fi
			else
				printf "${bred} Skipping XSS: Too many URLs to test, try with --deep flag${reset}\n"
			fi
		fi
	fi
	end_func "Results are saved in vulns/xss.txt" ${FUNCNAME[0]}
else
	if [ "$XSS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/xss.txt" ]; then
			printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to XSS ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi