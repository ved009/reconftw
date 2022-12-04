#!/usr/bin/env bash

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
  # display improved help information
  echo "Usage: ${name} -d domain -o output_folder"
  echo ""
  echo "Searches emails for the given domain and saves the output in the specified folder."
  echo ""
  echo "Options:"
  echo "  -d, --domain          Domain to search emails for"
  echo "  -o, --output-folder   Folder to save the output in (default: osint/dorks.txt)"
  echo "  -h, --help            Shows this help message"
  exit 0
fi

# initialize variables for the domain and output folder
domain=""
output_folder=""

# process command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--domain)
      domain="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--output-folder)
      output_folder="$2"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      echo "Error: Invalid option: $key"
      exit 1
      ;;
  esac
done

# check if a domain was provided
if [[ -z "$domain" ]]; then
  # display error message if no domain is provided
  echo "Error: No domain provided. Use ${name} -h for usage information."
  exit 1
fi

# check if an output folder was provided
if [[ -z "$output_folder" ]]; then
  # use the default output folder if no output folder was provided
  output_folder="osint"
fi

# check if the tools directory exists
if [[ ! -d "$tools" ]]; then
  # display error message if the tools directory does not exist
  echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
  exit 1
fi

mkdir -p .tmp

# run the tool for the given args and save the output in the specified folder
emailfinder -d $domain 2>>"$LOGFILE" | anew -q .tmp/emailfinder.txt
[ -s ".tmp/emailfinder.txt" ] && cat .tmp/emailfinder.txt | grep "@" | grep -iv "|_" | anew -q ${output_folder}/emails.txt

pushd "$tools/theHarvester" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
python3 theHarvester.py -d $domain -b all -f .tmp/harvester.json 2>>"$LOGFILE" &>/dev/null
popd || { echo "Failed to cd to the original directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }

if [ -s ".tmp/harvester.json" ]; then
	cat .tmp/harvester.json | jq -r 'try .emails[]' 2>/dev/null | anew -q osint/emails.txt
	cat .tmp/harvester.json | jq -r 'try .linkedin_people[]' 2>/dev/null | anew -q osint/employees.txt
	cat .tmp/harvester.json | jq -r 'try .linkedin_links[]' 2>/dev/null | anew -q osint/linkedin.txt
fi

h8mail -t $domain -q domain --loose -c $tools/h8mail_config.ini -j .tmp/h8_results.json 2>>"$LOGFILE" &>/dev/null
[ -s ".tmp/h8_results.json" ] && cat .tmp/h8_results.json | jq -r '.targets[0] | .data[] | .[]' | awk '{print $12}' | anew -q osint/h8mail.txt
PWNDB_STATUS=$(timeout 30s curl -Is --socks5-hostname localhost:9050 http://pwndb2am4tzkvold.onion | grep HTTP | cut -d ' ' -f2)
if [ "$PWNDB_STATUS" = 200 ]; then
	cd "$tools/pwndb" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	python3 pwndb.py --target "@${domain}" | sed '/^[-]/d' | anew -q $dir/osint/passwords.txt
	cd "$dir" || { echo "Failed to cd directory in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
	[ -s "osint/passwords.txt" ] && sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" osint/passwords.txt
	[ -s "osint/passwords.txt" ] && sed -i '1,2d' osint/passwords.txt
else
	text="${yellow}\n pwndb is currently down :(\n\n Check xjypo5vzgmo7jca6b322dnqbsdnp3amd24ybx26x5nxbusccjkm4pwid.onion${reset}\n"
	printf "${text}" && printf "${text}" | $NOTIFY
fi