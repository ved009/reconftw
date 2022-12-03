#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$S3BUCKETS" = true ] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
	start_func ${FUNCNAME[0]} "AWS S3 buckets search"
	# S3Scanner
	if [ ! "$AXIOM" = true ]; then
		[ -s "subdomains/subdomains.txt" ] && s3scanner scan -f subdomains/subdomains.txt | anew -q .tmp/s3buckets.txt
	else
		axiom-scan subdomains/subdomains.txt -m s3scanner -o .tmp/s3buckets_tmp.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		[ -s ".tmp/s3buckets_tmp.txt" ] && cat .tmp/s3buckets_tmp.txt .tmp/s3buckets_tmp2.txt 2>>"$LOGFILE" | anew -q .tmp/s3buckets.txt && sed -i '/^$/d' .tmp/s3buckets.txt
	fi
	# Cloudenum
	keyword=${domain%%.*}
	python3 ~/Tools/cloud_enum/cloud_enum.py -k $keyword -qs -l .tmp/output_cloud.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES1=$(cat .tmp/output_cloud.txt 2>>"$LOGFILE" | sed '/^#/d' | sed '/^$/d' | anew subdomains/cloud_assets.txt | wc -l)
	if [ "$NUMOFLINES1" -gt 0 ]; then
		notification "${NUMOFLINES1} new cloud assets found" info
	fi
	NUMOFLINES2=$(cat .tmp/s3buckets.txt 2>>"$LOGFILE" | grep -aiv "not_exist" | grep -aiv "Warning:" | grep -aiv "invalid_name" | grep -aiv "^http" | awk 'NF' | anew subdomains/s3buckets.txt | sed '/^$/d' | wc -l)
	if [ "$NUMOFLINES2" -gt 0 ]; then
		notification "${NUMOFLINES2} new S3 buckets found" info
	fi
	if [ "$BBRF_CONNECTION" = true ]; then
		[ -s "subdomains/cloud_assets.txt" ] && cat subdomains/cloud_assets.txt | grep -aEo 'https?://[^ ]+' | sed 's/[ \t]*$//' | bbrf url add - -t cloud_assets:true 2>>"$LOGFILE" &>/dev/null
		[ -s "subdomains/s3buckets.txt" ] && cat subdomains/s3buckets.txt | cut -d'|' -f1 | sed 's/[ \t]*$//' | bbrf domain update - -t s3bucket:true 2>>"$LOGFILE" &>/dev/null
	fi
	end_func "Results are saved in subdomains/s3buckets.txt and subdomains/cloud_assets.txt" ${FUNCNAME[0]}
else
	if [ "$S3BUCKETS" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]]; then
		return
	else
		if [ "$S3BUCKETS" = false ]; then
			printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
		else
			printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
		fi
	fi
fi