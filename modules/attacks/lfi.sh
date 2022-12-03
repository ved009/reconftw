#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$LFI" = true ] && [ -s "gf/lfi.txt" ]; then
	start_func ${FUNCNAME[0]} "LFI checks"
	if [ -s "gf/lfi.txt" ]; then
		cat gf/lfi.txt | qsreplace FUZZ | sed '/FUZZ/!d' | anew -q .tmp/tmp_lfi.txt
		if [ "$DEEP" = true ] || [[ $(cat .tmp/tmp_lfi.txt | wc -l) -le $DEEP_LIMIT ]]; then
			rush -i .tmp/tmp_lfi.txt -j ${INTERLACE_THREADS} "ffuf -v -r -t ${FFUF_THREADS} -rate ${FFUF_RATELIMIT} -H \"${HEADER}\" -w ${lfi_wordlist} -u \"{}\" -mr \"root:\" " 2>/dev/null | grep "URL" | sed 's/| URL | //' | anew -q vulns/lfi.txt
			#interlace -tL .tmp/tmp_lfi.txt -threads ${INTERLACE_THREADS} -c "ffuf -v -r -t ${FFUF_THREADS} -rate ${FFUF_RATELIMIT} -H \"${HEADER}\" -w ${lfi_wordlist} -u \"_target_\" -mr \"root:\" " 2>/dev/null | grep "URL" | sed 's/| URL | //' | anew -q vulns/lfi.txt
			end_func "Results are saved in vulns/lfi.txt" ${FUNCNAME[0]}
		else
			end_func "Skipping LFI: Too many URLs to test, try with --deep flag" ${FUNCNAME[0]}
		fi
	fi
else
	if [ "$LFI" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [ ! -s "gf/lfi.txt" ]; then
		printf "\n${yellow} ${FUNCNAME[0]} No URLs potentially vulnerables to LFI ${reset}\n\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi