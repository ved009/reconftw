#!/usr/bin/env bash

# store the script name in a variable for use in the help message
name=`basename "$0"`

# check if the -h flag is provided
if [[ "$1" == "-h" ]]; then
  # display improved help information
  echo "Usage: ${name} -d domain -o output_folder"
  echo ""
  echo "Runs dorks_hunter in passive mode for the given domain and saves the output in the specified folder."
  echo ""
  echo "Options:"
  echo "  -d, --domain          Domain to run dorks_hunter for"
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
  output_folder="osint/dorks.txt"
fi

# check if the tools directory exists
if [[ ! -d "$tools" ]]; then
  # display error message if the tools directory does not exist
  echo "Error: 'tools' directory not found. Make sure it exists and is in the current working directory."
  exit 1
fi

# run the tool for the given args and save the output in the specified folder
python3 "$tools/dorks_hunter/dorks_hunter.py" -d "$domain" -o "$output_folder"
