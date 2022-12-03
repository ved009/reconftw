#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$CMS_SCANNER" = true ]; then
	start_func ${FUNCNAME[0]} "CMS Scanner"
	mkdir -p $dir/cms && rm -rf $dir/cms/*
	[ ! -s ".tmp/webs_all.txt" ] && cat webs/webs.txt webs/webs_uncommon_ports.txt 2>/dev/null | anew -q .tmp/webs_all.txt
	if [ -s ".tmp/webs_all.txt" ]; then
		tr '\n' ',' < .tmp/webs_all.txt > .tmp/cms.txt
		timeout -k 30 $CMSSCAN_TIMEOUT python3 $tools/CMSeeK/cmseek.py -l .tmp/cms.txt --batch -r 2>>"$LOGFILE" &>/dev/null
		exit_status=$?
		if [[ $exit_status -eq 125 ]]; then
			echo "TIMEOUT cmseek.py - investigate manually for $dir" >> "$LOGFILE"
			end_func "TIMEOUT cmseek.py - investigate manually for $dir" ${FUNCNAME[0]}
			return
		elif [[ $exit_status -ne 0 ]]; then
			echo "ERROR cmseek.py - investigate manually for $dir" >> "$LOGFILE"
			end_func "ERROR cmseek.py - investigate manually for $dir" ${FUNCNAME[0]}
			return
		fi	# otherwise Assume we have a successfully exited cmseek
		for sub in $(cat .tmp/webs_all.txt); do
			sub_out=$(echo $sub | sed -e 's|^[^/]*//||' -e 's|/.*$||')
			cms_id=$(cat $tools/CMSeeK/Result/${sub_out}/cms.json 2>/dev/null | jq -r 'try .cms_id')
			if [ -z "$cms_id" ]; then
				rm -rf $tools/CMSeeK/Result/${sub_out}
			else
				mv -f $tools/CMSeeK/Result/${sub_out} $dir/cms/
			fi
		done
		end_func "Results are saved in $domain/cms/*subdomain* folder" ${FUNCNAME[0]}
	else
		end_func "No $domain/web/webs.txts file found, cms scanner skipped" ${FUNCNAME[0]}
	fi
else
	if [ "$CMS_SCANNER" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi