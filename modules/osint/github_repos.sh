#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$GITHUB_REPOS" = true ] && [ "$OSINT" = true ]; then
	start_func ${FUNCNAME[0]} "Github Repos analysis in process"
	if [ -s "${GITHUB_TOKENS}" ]; then
		GH_TOKEN=$(cat ${GITHUB_TOKENS} | head -1)
		echo $domain | unfurl format %r > .tmp/company_name.txt
		enumerepo -token-string ${GH_TOKEN} -usernames .tmp/company_name.txt -o .tmp/company_repos.txt 2>>"$LOGFILE" &>/dev/null
		[ -s .tmp/company_repos.txt ] && cat .tmp/company_repos.txt | jq -r '.[].repos[]|.url' > .tmp/company_repos_url.txt 2>>"$LOGFILE" &>/dev/null
		rush -i .tmp/company_repos_url.txt -j ${INTERLACE_THREADS} "trufflehog git {} -j | jq -c >> osint/github_company_secrets.json" 2>>"$LOGFILE" &>/dev/null
	else
		printf "\n${bred} Required file ${GITHUB_TOKENS} not exists or empty${reset}\n"
	fi
	end_func "Results are saved in $domain/osint/github_company_secrets.json" ${FUNCNAME[0]}
else
	if [ "$GITHUB_REPOS" = false ] || [ "$OSINT" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi