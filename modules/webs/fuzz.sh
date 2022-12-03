#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$FUZZ" = true ]; then
	start_func ${FUNCNAME[0]} "Web directory fuzzing"
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ -s ".tmp/webs_all.txt" ]; then
		mkdir -p $dir/fuzzing $dir/.tmp/fuzzing
		if [ ! "$AXIOM" = true ]; then
			rush -i .tmp/webs_all.txt -j ${INTERLACE_THREADS} "ffuf ${FFUF_FLAGS} -t ${FFUF_THREADS} -rate ${FFUF_RATELIMIT} -H '${HEADER}' -w ${fuzz_wordlist} -maxtime ${FFUF_MAXTIME} -u '{}/FUZZ' -json 2>/dev/null | anew -q .tmp/fuzzing_full.json"
			[ -s "$dir/.tmp/fuzzing_full.json" ] && cat $dir/.tmp/fuzzing_full.json | jq -r '. | "\(.status) \(.length) \(.url)"' | sort | anew -q $dir/fuzzing/fuzzing_full.txt
		else
			axiom-exec 'wget -q -O - https://raw.githubusercontent.com/six2dez/OneListForAll/main/onelistforallmicro.txt > /home/op/lists/fuzz_wordlist.txt' &>/dev/null
			axiom-scan .tmp/webs_all.txt -m ffuf -w /home/op/lists/fuzz_wordlist.txt -H \"${HEADER}\" $FFUF_FLAGS -s -maxtime $FFUF_MAXTIME -of json -o $dir/.tmp/fuzzing/ffuf-content.json $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			[ -s "$dir/.tmp/fuzzing/ffuf-content.json" ] && cat $dir/.tmp/fuzzing/ffuf-content.json | jq -r 'try .results[] | "\(.status) \(.length) \(.url)"' | sort > $dir/.tmp/fuzzing/ffuf-content.tmp
			for sub in $(cat .tmp/webs_all.txt); do
				sub_out=$(echo $sub | sed -e 's|^[^/]*//||' -e 's|/.*$||')
				grep "$sub" $dir/.tmp/fuzzing/ffuf-content.tmp | anew -q $dir/fuzzing/${sub_out}.txt
			done
			find $dir/fuzzing/ -type f -iname "*.txt" -exec cat {} + 2>>"$LOGFILE" | anew -q $dir/fuzzing/fuzzing_full.txt
		fi
		end_func "Results are saved in $domain/fuzzing/*subdomain*.txt" ${FUNCNAME[0]}
	else
		end_func "No $domain/web/webs.txts file found, fuzzing skipped " ${FUNCNAME[0]}
	fi
else
	if [ "$FUZZ" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi