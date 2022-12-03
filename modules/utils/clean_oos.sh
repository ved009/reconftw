#!/usr/bin/env bash

if [ -z "$1" ]; then
	cat $1 | while read outscoped
	do
		if  grep -q  "^[*]" <<< $outscoped
		then
			outscoped="${outscoped:1}"
			sed -i /"$outscoped$"/d  $2
		else
		sed -i /$outscoped/d  $2
		fi
	done
fi