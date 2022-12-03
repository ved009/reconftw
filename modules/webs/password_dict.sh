#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$PASSWORD_DICT" = true ];	then
	start_func ${FUNCNAME[0]} "Password dictionary generation"
	word=${domain%%.*}
	python3 $tools/pydictor/pydictor.py -extend $word --leet 0 1 2 11 21 --len ${PASSWORD_MIN_LENGTH} ${PASSWORD_MAX_LENGTH} -o webs/password_dict.txt 2>>"$LOGFILE" &>/dev/null
	end_func "Results are saved in $domain/webs/password_dict.txt" ${FUNCNAME[0]}
else
	if [ "$PASSWORD_DICT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi