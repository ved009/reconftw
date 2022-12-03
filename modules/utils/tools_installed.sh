#!/usr/bin/env bash

printf "\n\n${bgreen}#######################################################################${reset}\n"
printf "${bblue} Checking installed tools ${reset}\n\n"
allinstalled=true
[ -n "$GOPATH" ] || { printf "${bred} [*] GOPATH var			[NO]${reset}\n"; allinstalled=false;}
[ -n "$GOROOT" ] || { printf "${bred} [*] GOROOT var			[NO]${reset}\n"; allinstalled=false;}
[ -n "$PATH" ] || { printf "${bred} [*] PATH var			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/dorks_hunter/dorks_hunter.py" ] || { printf "${bred} [*] dorks_hunter		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/brutespray/brutespray.py" ] || { printf "${bred} [*] brutespray			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/theHarvester/theHarvester.py" ] || { printf "${bred} [*] theHarvester		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/fav-up/favUp.py" ] || { printf "${bred} [*] fav-up			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/Corsy/corsy.py" ] || { printf "${bred} [*] Corsy			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/testssl.sh/testssl.sh" ] || { printf "${bred} [*] testssl			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/CMSeeK/cmseek.py" ] || { printf "${bred} [*] CMSeeK			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/ctfr/ctfr.py" ] || { printf "${bred} [*] ctfr			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/fuzz_wordlist.txt" ] || { printf "${bred} [*] OneListForAll		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/xnLinkFinder/xnLinkFinder.py" ] || { printf "${bred} [*] xnLinkFinder		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/commix/commix.py" ] || { printf "${bred} [*] commix			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/getjswords.py" ] || { printf "${bred} [*] getjswords   		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/JSA/jsa.py" ] || { printf "${bred} [*] JSA			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/cloud_enum/cloud_enum.py" ] || { printf "${bred} [*] cloud_enum			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/ultimate-nmap-parser/ultimate-nmap-parser.sh" ] || { printf "${bred} [*] nmap-parse-output		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/pydictor/pydictor.py" ] || { printf "${bred} [*] pydictor   		[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/urless/urless.py" ] || { printf "${bred} [*] urless			[NO]${reset}\n"; allinstalled=false;}
[ -f "$tools/smuggler/smuggler.py" ] || { printf "${bred} [*] smuggler			[NO]${reset}\n"; allinstalled=false;}
which github-endpoints &>/dev/null || { printf "${bred} [*] github-endpoints		[NO]${reset}\n"; allinstalled=false;}
which github-subdomains &>/dev/null || { printf "${bred} [*] github-subdomains		[NO]${reset}\n"; allinstalled=false;}
which gospider &>/dev/null || { printf "${bred} [*] gospider			[NO]${reset}\n"; allinstalled=false;}
which wafw00f &>/dev/null || { printf "${bred} [*] wafw00f			[NO]${reset}\n"; allinstalled=false;}
which dnsvalidator &>/dev/null || { printf "${bred} [*] dnsvalidator		[NO]${reset}\n"; allinstalled=false;}
which gowitness &>/dev/null || { printf "${bred} [*] gowitness			[NO]${reset}\n"; allinstalled=false;}
which amass &>/dev/null || { printf "${bred} [*] Amass			[NO]${reset}\n"; allinstalled=false;}
which waybackurls &>/dev/null || { printf "${bred} [*] Waybackurls		[NO]${reset}\n"; allinstalled=false;}
which gau &>/dev/null || { printf "${bred} [*] gau			[NO]${reset}\n"; allinstalled=false;}
which dnsx &>/dev/null || { printf "${bred} [*] dnsx			[NO]${reset}\n"; allinstalled=false;}
which gotator &>/dev/null || { printf "${bred} [*] gotator			[NO]${reset}\n"; allinstalled=false;}
which nuclei &>/dev/null || { printf "${bred} [*] Nuclei			[NO]${reset}\n"; allinstalled=false;}
[ -d ~/nuclei-templates ] || { printf "${bred} [*] Nuclei templates	[NO]${reset}\n"; allinstalled=false;}
which gf &>/dev/null || { printf "${bred} [*] Gf				[NO]${reset}\n"; allinstalled=false;}
which Gxss &>/dev/null || { printf "${bred} [*] Gxss			[NO]${reset}\n"; allinstalled=false;}
which subjs &>/dev/null || { printf "${bred} [*] subjs			[NO]${reset}\n"; allinstalled=false;}
which ffuf &>/dev/null || { printf "${bred} [*] ffuf			[NO]${reset}\n"; allinstalled=false;}
which massdns &>/dev/null || { printf "${bred} [*] Massdns			[NO]${reset}\n"; allinstalled=false;}
which qsreplace &>/dev/null || { printf "${bred} [*] qsreplace			[NO]${reset}\n"; allinstalled=false;}
which rush &>/dev/null || { printf "${bred} [*] rush			[NO]${reset}\n"; allinstalled=false;}
which anew &>/dev/null || { printf "${bred} [*] Anew			[NO]${reset}\n"; allinstalled=false;}
which unfurl &>/dev/null || { printf "${bred} [*] unfurl			[NO]${reset}\n"; allinstalled=false;}
which crlfuzz &>/dev/null || { printf "${bred} [*] crlfuzz			[NO]${reset}\n"; allinstalled=false;}
which httpx &>/dev/null || { printf "${bred} [*] Httpx			[NO]${reset}\n${reset}"; allinstalled=false;}
which jq &>/dev/null || { printf "${bred} [*] jq				[NO]${reset}\n${reset}"; allinstalled=false;}
which notify &>/dev/null || { printf "${bred} [*] notify			[NO]${reset}\n${reset}"; allinstalled=false;}
which dalfox &>/dev/null || { printf "${bred} [*] dalfox			[NO]${reset}\n${reset}"; allinstalled=false;}
which puredns &>/dev/null || { printf "${bred} [*] puredns			[NO]${reset}\n${reset}"; allinstalled=false;}
which unimap &>/dev/null || { printf "${bred} [*] unimap			[NO]${reset}\n${reset}"; allinstalled=false;}
which emailfinder &>/dev/null || { printf "${bred} [*] emailfinder		[NO]${reset}\n"; allinstalled=false;}
which analyticsrelationships &>/dev/null || { printf "${bred} [*] analyticsrelationships	[NO]${reset}\n"; allinstalled=false;}
which mapcidr &>/dev/null || { printf "${bred} [*] mapcidr			[NO]${reset}\n"; allinstalled=false;}
which ppfuzz &>/dev/null || { printf "${bred} [*] ppfuzz			[NO]${reset}\n"; allinstalled=false;}
which searchsploit &>/dev/null || { printf "${bred} [*] searchsploit		[NO]${reset}\n"; allinstalled=false;}
which ipcdn &>/dev/null || { printf "${bred} [*] ipcdn			[NO]${reset}\n"; allinstalled=false;}
which interactsh-client &>/dev/null || { printf "${bred} [*] interactsh-client		[NO]${reset}\n"; allinstalled=false;}
which tlsx &>/dev/null || { printf "${bred} [*] tlsx			[NO]${reset}\n"; allinstalled=false;}
which bbrf &>/dev/null || { printf "${bred} [*] bbrf			[NO]${reset}\n"; allinstalled=false;}
which smap &>/dev/null || { printf "${bred} [*] smap			[NO]${reset}\n"; allinstalled=false;}
which gitdorks_go &>/dev/null || { printf "${bred} [*] gitdorks_go		[NO]${reset}\n"; allinstalled=false;}
which ripgen &>/dev/null || { printf "${bred} [*] ripgen			[NO]${reset}\n${reset}"; allinstalled=false;}
which dsieve &>/dev/null || { printf "${bred} [*] dsieve			[NO]${reset}\n${reset}"; allinstalled=false;}
which inscope &>/dev/null || { printf "${bred} [*] inscope			[NO]${reset}\n${reset}"; allinstalled=false;}
which enumerepo &>/dev/null || { printf "${bred} [*] enumerepo			[NO]${reset}\n${reset}"; allinstalled=false;}
which trufflehog &>/dev/null || { printf "${bred} [*] trufflehog			[NO]${reset}\n${reset}"; allinstalled=false;}
which Web-Cache-Vulnerability-Scanner &>/dev/null || { printf "${bred} [*] Web-Cache-Vulnerability-Scanner [NO]${reset}\n"; allinstalled=false;}
which subfinder &>/dev/null || { printf "${bred} [*] subfinder			[NO]${reset}\n${reset}"; allinstalled=false;}
if [ "${allinstalled}" = true ]; then
	printf "${bgreen} Good! All installed! ${reset}\n\n"
else
	printf "\n${yellow} Try running the installer script again ./install.sh"
	printf "\n${yellow} If it fails for any reason try to install manually the tools missed"
	printf "\n${yellow} Finally remember to set the ${bred}\$tools${yellow} variable at the start of this script"
	printf "\n${yellow} If nothing works and the world is gonna end you can always ping me :D ${reset}\n\n"
fi
printf "${bblue} Tools check finished\n"
printf "${bgreen}#######################################################################\n${reset}"