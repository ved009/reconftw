#!/usr/bin/env bash

if [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; then
	start_subfunc ${FUNCNAME[0]} "Running : DNS Subdomain Enumeration and PTR search"
	if [ ! "$AXIOM" = true ]; then
		[ -s "subdomains/subdomains.txt" ] && cat subdomains/subdomains.txt | dnsx -r $resolvers_trusted -a -aaaa -cname -ns -ptr -mx -soa -silent -retry 3 -json -o subdomains/subdomains_dnsregs.json 2>>"$LOGFILE" &>/dev/null
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try .a[], try .aaaa[], try .cname[], try .ns[], try .ptr[], try .mx[], try .soa[]' 2>/dev/null | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try .a[]' | sort -u | dnsx -retry 3 -silent -ptr -r $resolvers_trusted -resp-only 2>/dev/null | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try "\(.host) - \(.a[])"' 2>/dev/null | sort -u -k2 | anew -q subdomains/subdomains_ips.txt
		resolvers_update_quick_local
		[ -s ".tmp/subdomains_dns.txt" ] && puredns resolve .tmp/subdomains_dns.txt -w .tmp/subdomains_dns_resolved.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
	else
		[ -s "subdomains/subdomains.txt" ] && axiom-scan subdomains/subdomains.txt -m dnsx -retry 3 -a -aaaa -cname -ns -ptr -mx -soa -json -o subdomains/subdomains_dnsregs.json $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try .a[]' | sort -u | anew -q .tmp/subdomains_dns_a_records.txt
		[ -s ".tmp/subdomains_dns_a_records.txt" ] && axiom-scan .tmp/subdomains_dns_a_records.txt -m dnsx -retry 3 -ptr -resp-only -o .tmp/subdomains_dns_ptr_reverse.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null 
		[ -s ".tmp/subdomains_dns_ptr_reverse.txt" ] && cat .tmp/subdomains_dns_ptr_reverse.txt | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try .a[], try .aaaa[], try .cname[], try .ns[], try .ptr[], try .mx[], try .soa[]' 2>/dev/null | grep ".$domain$" | anew -q .tmp/subdomains_dns.txt
		[ -s "subdomains/subdomains_dnsregs.json" ] && cat subdomains/subdomains_dnsregs.json | jq -r 'try "\(.host) - \(.a[])"' 2>/dev/null | sort -u -k2 | anew -q subdomains/subdomains_ips.txt
		resolvers_update_quick_axiom
		[ -s ".tmp/subdomains_dns.txt" ] && axiom-scan .tmp/subdomains_dns.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/subdomains_dns_resolved.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	[[ "$INSCOPE" = true ]] && check_inscope .tmp/subdomains_dns_resolved.txt 2>>"$LOGFILE" &>/dev/null
	NUMOFLINES=$(cat .tmp/subdomains_dns_resolved.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | anew subdomains/subdomains.txt | sed '/^$/d' | wc -l)
	end_subfunc "${NUMOFLINES} new subs (dns resolution)" ${FUNCNAME[0]}
else
	printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
fi