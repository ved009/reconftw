#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	printf "\n${yellow} no file provided to send ${reset}\n"
else
	if [[ -z "$NOTIFY_CONFIG" ]]; then
		NOTIFY_CONFIG=~/.config/notify/provider-config.yaml
	fi
	if [ -n "$(find "${1}" -prune -size +8000000c)" ]; then
    	printf '%s is larger than 8MB, sending over transfer.sh\n' "${1}"
		transfer "${1}" | notify
		return 0
	fi
	if grep -q '^ telegram\|^telegram\|^    telegram' $NOTIFY_CONFIG ; then
		notification "Sending ${domain} data over Telegram" info
		telegram_chat_id=$(cat ${NOTIFY_CONFIG} | grep '^    telegram_chat_id\|^telegram_chat_id\|^    telegram_chat_id' | xargs | cut -d' ' -f2)
		telegram_key=$(cat ${NOTIFY_CONFIG} | grep '^    telegram_api_key\|^telegram_api_key\|^    telegram_apikey' | xargs | cut -d' ' -f2 )
		curl -F document=@${1} "https://api.telegram.org/bot${telegram_key}/sendDocument?chat_id=${telegram_chat_id}" &>/dev/null
	fi
	if grep -q '^ discord\|^discord\|^    discord' $NOTIFY_CONFIG ; then
		notification "Sending ${domain} data over Discord" info
		discord_url=$(cat ${NOTIFY_CONFIG} | grep '^ discord_webhook_url\|^discord_webhook_url\|^    discord_webhook_url' | xargs | cut -d' ' -f2)
		curl -v -i -H "Accept: application/json" -H "Content-Type: multipart/form-data" -X POST -F file1=@${1} $discord_url &>/dev/null
	fi
	if [[ -n "$slack_channel" ]] && [[ -n "$slack_auth" ]]; then
		notification "Sending ${domain} data over Slack" info
		curl -F file=@${1} -F "initial_comment=reconftw zip file" -F channels=${slack_channel} -H "Authorization: Bearer ${slack_auth}" https://slack.com/api/files.upload &>/dev/null
	fi
fi