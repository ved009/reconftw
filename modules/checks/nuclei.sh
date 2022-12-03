#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$NUCLEICHECK" = true ]; then
	start_func ${FUNCNAME[0]} "Templates based web scanner"
	nuclei -update-templates 2>>"$LOGFILE" &>/dev/null
	mkdir -p nuclei_output
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	[ ! -s ".tmp/webs_subs.txt" ] && cat subdomains/subdomains.txt .tmp/webs_all.txt 2>>"$LOGFILE" | anew -q .tmp/webs_subs.txt
	if [ ! "$AXIOM" = true ]; then
		set -f                      # avoid globbing (expansion of *).
		array=(${NUCLEI_SEVERITY//,/ })
		for i in "${!array[@]}"
		do
			crit=${array[i]}
			printf "${yellow}\n Running : Nuclei $crit ${reset}\n\n"
			cat .tmp/webs_subs.txt 2>/dev/null | nuclei $NUCLEI_FLAGS -severity $crit -r $resolvers_trusted -rl $NUCLEI_RATELIMIT -o nuclei_output/${crit}.txt
		done
		printf "\n\n"
	else
		if [ -s ".tmp/webs_subs.txt" ]; then
			set -f                      # avoid globbing (expansion of *).
			array=(${NUCLEI_SEVERITY//,/ })
			for i in "${!array[@]}"
			do
				crit=${array[i]}
				printf "${yellow}\n Running : Nuclei $crit ${reset}\n\n"
				axiom-scan .tmp/webs_subs.txt -m nuclei -severity ${crit} -rl $NUCLEI_RATELIMIT -o nuclei_output/${crit}.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
			done
			printf "\n\n"
		fi
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "nuclei_output/info.txt" ] && cat nuclei_output/info.txt | cut -d' ' -f6 | sort -u | bbrf url add - -t nuclei:${crit} 2>>"$LOGFILE" &>/dev/null
		[ -s "nuclei_output/low.txt" ] && cat nuclei_output/low.txt | cut -d' ' -f6 | sort -u | bbrf url add - -t nuclei:${crit} 2>>"$LOGFILE" &>/dev/null
		[ -s "nuclei_output/medium.txt" ] && cat nuclei_output/medium.txt | cut -d' ' -f6 | sort -u | bbrf url add - -t nuclei:${crit} 2>>"$LOGFILE" &>/dev/null
		[ -s "nuclei_output/high.txt" ] && cat nuclei_output/high.txt | cut -d' ' -f6 | sort -u | bbrf url add - -t nuclei:${crit} 2>>"$LOGFILE" &>/dev/null
		[ -s "nuclei_output/critical.txt" ] && cat nuclei_output/critical.txt | cut -d' ' -f6 | sort -u | bbrf url add - -t nuclei:${crit} 2>>"$LOGFILE" &>/dev/null
	fi
	end_func "Results are saved in $domain/nuclei_output folder" ${FUNCNAME[0]}
else
	if [ "$NUCLEICHECK" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi