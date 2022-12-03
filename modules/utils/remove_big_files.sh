#!/usr/bin/env bash

eval rm -rf .tmp/gotator*.txt 2>>"$LOGFILE"
eval rm -rf .tmp/brute_recursive_wordlist.txt 2>>"$LOGFILE"
eval rm -rf .tmp/subs_dns_tko.txt  2>>"$LOGFILE"
eval rm -rf .tmp/subs_no_resolved.txt .tmp/subdomains_dns.txt .tmp/brute_dns_tko.txt .tmp/scrap_subs.txt .tmp/analytics_subs_clean.txt .tmp/gotator1.txt .tmp/gotator2.txt .tmp/passive_recursive.txt .tmp/brute_recursive_wordlist.txt .tmp/gotator1_recursive.txt .tmp/gotator2_recursive.txt 2>>"$LOGFILE"
eval find .tmp -type f -size +200M -delete 2>>"$LOGFILE"