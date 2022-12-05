#!/usr/bin/env bash

source $HOME/.reconftw/reconftw.cfg	

# Array of repos
repos=(
	"GOPATH"
	"GOROOT"
	"PATH"
	"$tools/dorks_hunter/dorks_hunter.py"
	"$tools/brutespray/brutespray.py"
	"$tools/theHarvester/theHarvester.py"
	"$tools/fav-up/favUp.py"
	"$tools/Corsy/corsy.py"
	"$tools/testssl.sh/testssl.sh"
	"$tools/CMSeeK/cmseek.py"
	"$tools/ctfr/ctfr.py"
	"$tools/fuzz_wordlist.txt"
	"$tools/xnLinkFinder/xnLinkFinder.py"
	"$tools/commix/commix.py"
	"$tools/getjswords.py"
	"$tools/JSA/jsa.py"
	"$tools/cloud_enum/cloud_enum.py"
	"$tools/ultimate-nmap-parser/ultimate-nmap-parser.sh"
	"$tools/pydictor/pydictor.py"
	"$tools/urless/urless.py"
	"$tools/smuggler/smuggler.py"
	)

# Array of Go tools
gotools=(
		github-endpoints
		github-subdomains
		gospider
		wafw00f
		dnsvalidator
		gowitness
		amass
		waybackurls
		gau
		dnsx
		gotator
		nuclei
		Gf
		Gxss
		subjs
		ffuf
		massdns
		qsreplace
		rush
		anew
		unfurl
		crlfuzz
		httpx
		jq
		notify
		dalfox
	)

printf "\n\n${bgreen}#######################################################################${reset}\n"
printf "${bblue} Checking installed tools ${reset}\n\n"
allinstalled=true

# loop through the array of tools and check if they are installed
for repo in "${repos[@]}"; do
    if [[ -z "$repo" ]]; then
        printf "${bred} [*] $tool			[NO]${reset}\n"
        allinstalled=false
    fi
done

# Iterate over the array, checking for each tool
for gotool in "${gotools[@]}"; do
    which $gotool &>/dev/null || { printf "${bred} [*] ${gotool} [NO]${reset}\n"; allinstalled=false;}
done

if ! test -d ~/nuclei-templates; then
    printf "${bred} [*] Nuclei templates [NO]${reset}\n"; allinstalled=false;
fi

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