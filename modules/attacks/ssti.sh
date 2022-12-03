#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SSTI" = true ] && [ -s "gf/ssti.txt" ]; then
	start_func ${FUNCNAME[0]} "SSTI checks"
	if [ -s "gf/ssti.txt" ]; then
		cat gf/ssti.txt | qsreplace FUZZ | sed '/FUZZ/!d'  | anew -q .tmp/tmp_ssti.txt
		if [ "$DEEP" = true ] || [[ $(cat .tmp/tmp_ssti.txt | wc -l) -le $DEEP_LIMIT ]]; then
			rush -i .tmp/tmp_ssti.txt -j ${INTERLACE_THREADS} "ffuf -v -r -t ${FFUF_THREADS} -rate ${FFUF_RATELIMIT} -H \"${HEADER}\" -w ${ssti_wordlist} -u \"{}\"-mr \"ssti49\" " 2>/dev/null | grep "URL" | sed 's/| URL | //' | anew -q vulns/ssti.txt
			#interlace -tL .tmp/tmp_ssti.txt -threads ${INTERLACE_THREADS} -c "ffuf -v -r -t ${FFUF_THREADS} -rate ${FFUF_RATELIMIT} -H \"${HEADER}\" -w ${ssti_wordlist} -u \"_target_\" -mr \"ssti49\" " 2>/dev/null | grep "URL" | sed 's/| URL | //' | anew -q vulns/ssti.txt
			end_func "Results are saved in vulns/ssti.txt" ${FUNCNAME[0]}
		else
			end_func "Skipping SSTI: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
		fi
	fi
else
	if [ "$SSTI" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/ssti.txt" ]; then
		printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to SSTI ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi