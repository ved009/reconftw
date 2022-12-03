#!/usr/bin/env bash

zip_name=`date +"%Y_%m_%d-%H.%M.%S"`
zip_name="$zip_name"_"$domain.zip"
(cd $dir && zip -r "../$zip_name" .)
echo "Sending zip file "${dir_output}/${zip_name}""
if [ -s "$dir_output/$zip_name" ]; then
	sendToNotify "$dir_output/$zip_name"
	rm -f "$dir_output/$zip_name"
else
	notification "No Zip file to send" warn
fi